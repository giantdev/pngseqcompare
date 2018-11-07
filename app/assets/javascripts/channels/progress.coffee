$(document).on "turbolinks:load", =>
  unqID = $("#unqid").val()

  App.progress = App.cable.subscriptions.create { channel: "ProgressChannel", unq: unqID },
    connected: ->
      # Called when the subscription is ready for use on the server

    disconnected: ->
      # Called when the subscription has been terminated by the server

    received: (data) ->
      console.log data.status + ' - Found ' + data.iden + ' identical images in Previous Draft. ' + data.progress + '/' + data.progressTotal

      val = parseInt(data.progress * 100 / data.progressTotal)
      $('.progress-bar').text(data.status)

      if data.status == 'preparing...'
        $('.progress-bar').css('width', '0%')
        $('.progress-bar').attr('aria-valuenow', 0)
        $('.result p').text('0% completed.');
        $('.progress').show()
        $('.result').show()
      else if data.status == 'in progress'
        $('.result p').text(val + '% completed. ' + data.iden + ' identical images are found so far.')
        $('.progress-bar').css('width', val+'%')
        $('.progress-bar').attr('aria-valuenow', val)
      else
        $('.result p').text('100% completed. ' + data.iden + ' identical images are found in previous sequence. Current sequence has ' + (data.total - data.iden) + ' unqiue images.')