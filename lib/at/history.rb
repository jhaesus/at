module At
  History = Redis.new(Settings.history.redis.to_h)
end
