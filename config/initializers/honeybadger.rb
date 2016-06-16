Honeybadger.start(Honeybadger::Config.new(At::Settings.honeybadger.to_h.merge(env: At.env)))
