module Helpers
  # Public: Temporarily change the ENV hash
  #
  # env - Hash of new keys and values to inject into ENV
  def with_env(env)
    original = ENV.to_hash
    env.each do |key, value|
      ENV[key] = value
    end

    yield

    ENV.replace(original)
  end
end
