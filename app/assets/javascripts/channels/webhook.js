var loaders = {};

function buildLogProgress(module_id, text) {
  var log = $('#log-' + module_id);

  clearInterval(loaders[module_id]);

  if (log.html()) {
    $('samp#log-loading-' + module_id).last().html('...');
    log.append('<small><samp> [OK]</samp></small><br>');
  }

  log.append('<small><samp>' + text + '</small></samp>');
  log.append('<small><samp id="log-loading-' + module_id + '"></samp></small>');

  loaders[module_id] = setInterval(function () {
    var wait = $('samp#log-loading-' + module_id).last();

    if (wait.html().length > 2)
      wait.html('');
    else
      wait.append('.');
  }, 100);
}

function buildLog(module_id, text) {
  var log = $('#log-' + module_id);

  clearInterval(loaders[module_id]);

  if (log.html()) {
    $('samp#log-loading-' + module_id).last().html('...');
    log.append('<br>');
  }

  log.append('<small><samp>' + text + '</small></samp>');
}

App.room = App.cable.subscriptions.create('WebhookChannel', {
  received: function (data) {
    if ($('#log-' + data.module_id).html() == undefined)
      return;

    switch (data.event) {
    case 'start':
      $('#log-' + data.module_id).show();
      $('#loading-' + data.module_id).css('display', 'inline-block');
      break;
    case 'log-progress':
      buildLogProgress(data.module_id, data.text);
      break;
    case 'log':
      buildLog(data.module_id, data.text);
      break;
    case 'finish':
      clearInterval(loaders[data.module_id]);
      $('#loading-' + data.module_id).hide();
      break;
    }
  }
});
