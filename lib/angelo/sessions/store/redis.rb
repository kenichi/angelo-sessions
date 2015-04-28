require 'redis'
require 'celluloid/redis'

module Angelo
  module Sessions
    class RedisStore < Store

      KEY_FMT = 'angelo:sessions:%s'

      class << self

        attr_writer :hash_key

        def hash_key
          unless @hash_key
            n = Sessions.store.name rescue 'default'
            @hash_key = KEY_FMT % n
          end
          @hash_key
        end

      end

      @@redis = ::Redis.new(driver: :celluloid)

      def fetch id
        hash_bin = @@redis.hget(RedisStore.hash_key, id)
        if hash_bin && !hash_bin.empty?
          Marshal.load hash_bin
        else
          Hash.new
        end
      end

      def save id, fields
        return nil if fields.length <= 0
        id = id ? id : generate_id
        @@redis.hset RedisStore.hash_key, id, Marshal.dump(fields)
        id
      end

    end
  end
end