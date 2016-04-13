
module Talk
  REDIS = Redis.new(db: 0)
  REDIS.del("users")

  def self.read(params)
    { status: 200, body: REDIS.sort("channels", order: "alpha") }
  end

  def self.create(params)
    payload = params[:body]
    if !payload.is_a?(Array) ||
      !payload.all?{ |p| p.is_a?(String) && p =~ /^[a-z]+$/ }

      return { status: 500, body: "Malformed payload" }
    end

    added, existed = payload.partition do |channel|
      REDIS.sadd("channels", channel)
    end

    return { status: 200, body: { added: added,
      existed: existed } }
  end

  def self.update(params)
  end

  def self.delete(params)
    payload = params[:body]
    if !payload.is_a?(Array) || !payload.all?{ |p| p.is_a?(String) }
      return { status: 500, body: "Malformed payload" }
    end

    deleted, not_found = payload.partition do |channel|
      REDIS.srem("channels", channel)
    end

    return { status: 200, body: { deleted: deleted,
      not_found: not_found } }
  end

  def self.channels(params)
    channels = REDIS.sort("channels", order: "alpha")
    if params["channel"].to_s !~ /^[a-z]+$/ ||
      !channels.include?(params["channel"])

      return
    end
    return [params["channel"]]
  end

  def self.reference(params)
    if params["user"].to_s !~ /^[a-z]+$/ ||
      REDIS.sismember("users", params["user"])

      return
    end
    REDIS.sadd("users", params["user"])
    return params["user"]
  end

  def self.subscribe(ref, channel)
    { action: "join", channel: channel, user: ref }
  end

  def self.unsubscribe(ref, channel)
    REDIS.srem("users", ref)
    { action: "leave", channel: channel, user: ref }
  end

  def self.pop(ref, channel, message)
    { status: 200, body: message }
  end

  def self.push(ref, channel, message)
    { action: "message", message: message, user: ref }
  end
end
