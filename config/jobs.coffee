Agenda = require('agenda')
agenda = new Agenda();
module.exports = (config) ->

  agenda.database(config.db,'agendaJobs')

  agenda.define 'delete old users', (job, done) ->
    console.log("deleted user")
    done()

  agenda.every '2 minutes', 'delete old users'

  agenda.start()

