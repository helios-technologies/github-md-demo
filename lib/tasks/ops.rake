namespace :ops do
  KUBE_DIR           = File.join('config', 'deploy', 'kube')
  KUBE_TMP_DIR       = File.join('tmp', 'kube')
  KUBE_DEPLOYMENTS = %w(dbmaster webfront)

  IMAGE_NAME    = 'gcr.io/hc-public/bc'
  IMAGE_VERSION = 'latest'

  logger = Logger.new(STDOUT)

  desc 'Deploy to staging'
  task :deploy do
    Rake::Task['ops:build'].invoke
    Rake::Task['ops:release'].invoke

    logger.info 'Deploying...'

    # -n for namespace
    unless `kubectl get pods 2>/dev/null`.include? 'dbmaster'
      logger.info 'Creating mysql pod...'
      sh "kubectl apply -f #{KUBE_TMP_DIR}/dbmaster"
    end

    unless `kubectl get ingress 2>/dev/null`.include? 'webfront'
      logger.info 'Creating ingress...'
      sh "kubectl apply -f #{KUBE_TMP_DIR}/webfront/ingress.yaml"
    end

    logger.info 'Applying new deployment...'
    sh "kubectl apply -f #{KUBE_TMP_DIR}/webfront/deployment.yaml"
    sh "kubectl apply -f #{KUBE_TMP_DIR}/webfront/service.yaml"
  end

  desc 'Build and tag a container'
  task :build do
    logger.info 'Building container...'

    sh 'tar --exclude=tmp/ -czvf tmp/bc.tar.gz .'
    sh 'docker build -t gcr.io/hc-public/bc:latest --rm -f config/deploy/Dockerfile .'
    sh 'docker tag gcr.io/hc-public/bc:latest gcr.io/hc-public/bc:latest'
    sh 'rm tmp/bc.tar.gz'
  end

  desc 'Push a container to the registry'
  task :release do
    logger.info 'Pushing container...'

    sh 'gcloud docker -- push gcr.io/hc-public/bc:latest'
  end

  desc 'Render kube files to tmp/kube'
  task :render do
    logger.info 'Rendering kube templates...'

    Dir.mkdir KUBE_TMP_DIR unless Dir.exist? KUBE_TMP_DIR

    KUBE_DEPLOYMENTS.each do |d|
      dir = File.join(KUBE_TMP_DIR, d)
      Dir.mkdir(dir) unless Dir.exist? dir
    end

    deploy_dir = ->(dir) { dir.split('/').last(2).join('/') }

    Dir["#{KUBE_DIR}/**/*.yaml"].each do |tmpl|
      dest = File.join(KUBE_TMP_DIR, deploy_dir.call(tmpl))
      logger.info "#{tmpl} -> #{dest}"

      FileUtils.cp(tmpl, dest)
    end
  end

  desc 'Remove tmp kube files'
  task :clean do
    logger.info 'Cleaning up...'
    FileUtils.rm_rf(KUBE_TMP_DIR)
  end
end
