require 'net/http'
require 'github/markup'

class Bootcamp::ModulesController < ApplicationController
  protect_from_forgery with: :null_session, only: :webhook

  def index
    @modules = Bootcamp::Module.all
  end

  def new
  end

  def show
    @module = Bootcamp::Module.find(params[:id])
  end

  def create
    mod = Bootcamp::Module.new(module_params)

    if mod.save
      redirect_to bootcamp_modules_path
    else
      redirect_to new_bootcamp_module_path, notice: mod.errors.full_messages
    end
  end

  def update
  end

  def destroy
  end

  def webhook
    puts request.body.read
    req = JSON.parse(request.body.read)

    @module = Bootcamp::Module.find_by_repo(req['repository']['html_url'])

    readme_data = Net::HTTP.get(URI.parse(req['repository']['contents_url'].gsub(/\{.+\}/, 'README.md')))

    readme = Net::HTTP.get(URI.parse(JSON.parse(readme_data)['download_url']))
    readme = readme.split(/\r\n|\r|\n/, 2).last.force_encoding(Encoding::UTF_8)

    readme = GitHub::Markup.render_s(GitHub::Markups::MARKUP_MARKDOWN, readme) if readme

    @module.description = readme

    @module.save
    render json: 'OK', status: 200
  end

  private

  def module_params
    params.require(:module).permit(:title, :repo)
  end
end
