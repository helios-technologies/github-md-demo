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

    ActionCable.server.broadcast(
      'webhook_channel',
      event: 'start',
      module_id: @module.id
    )

    ActionCable.server.broadcast(
      'webhook_channel',
      text: "The readme of #{@module.title} module has been updated. Updating module description",
      event: 'log-progress',
      module_id: @module.id
    )

    readme_data = JSON.parse(Net::HTTP.get(URI.parse(req['repository']['contents_url'].gsub(/\{.+\}/, 'README.md'))))

    if readme_data['message']
      ActionCable.server.broadcast(
        'webhook_channel',
        text: 'Can\'t load readme.',
        event: 'log',
        module_id: @module.id
      ) && ActionCable.server.broadcast(
        'webhook_channel',
        text: readme_data['message'],
        event: 'log',
        module_id: @module.id
      ) && ActionCable.server.broadcast(
        'webhook_channel',
        event: 'finish',
        module_id: @module.id
      ) && render(json: 'ERROR', status: 422) && return
    end

    readme_download_url = readme_data['download_url']

    ActionCable.server.broadcast(
      'webhook_channel',
      text: "Fetching readme from <a target='_blank' href='#{readme_download_url}'>#{readme_download_url}</a>",
      event: 'log-progress',
      module_id: @module.id
    )

    readme = Net::HTTP.get(URI.parse(readme_download_url))
    readme = readme.split(/\r\n|\r|\n/, 2).last.force_encoding(Encoding::UTF_8)

    ActionCable.server.broadcast(
      'webhook_channel',
      text: 'The readme was successfully fetched! Applying',
      event: 'log-progress',
      module_id: @module.id
    )

    readme = GitHub::Markup.render_s(GitHub::Markups::MARKUP_MARKDOWN, readme) if readme
    @module.description = readme

    @module.save

    ActionCable.server.broadcast(
      'webhook_channel',
      text: 'Module description was successfully updated!',
      event: 'log',
      module_id: @module.id
    )

    ActionCable.server.broadcast(
      'webhook_channel',
      event: 'finish',
      module_id: @module.id
    )

    render json: 'OK', status: 200
  end

  private

  def module_params
    params.require(:module).permit(:title, :repo)
  end
end
