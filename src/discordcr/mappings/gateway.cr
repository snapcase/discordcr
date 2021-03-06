require "./converters"
require "./user"
require "./channel"
require "./guild"

module Discord
  module Gateway
    struct ReadyPayload
      JSON.mapping(
        v: UInt8,
        user: User,
        private_channels: Array(PrivateChannel),
        guilds: Array(UnavailableGuild),
        session_id: String
      )
    end

    struct ResumedPayload
      JSON.mapping(
        _trace: Array(String)
      )
    end

    struct IdentifyPacket
      def initialize(token, properties, large_threshold, compress, shard)
        @op = Discord::Client::OP_IDENTIFY
        @d = IdentifyPayload.new(token, properties, large_threshold, compress, shard)
      end

      JSON.mapping(
        op: Int32,
        d: IdentifyPayload
      )
    end

    struct IdentifyPayload
      def initialize(@token, @properties, @compress, @large_threshold, @shard)
      end

      JSON.mapping({
        token:           String,
        properties:      IdentifyProperties,
        compress:        Bool,
        large_threshold: Int32,
        shard:           Tuple(Int32, Int32)?,
      })
    end

    struct IdentifyProperties
      def initialize(@os, @browser, @device, @referrer, @referring_domain)
      end

      JSON.mapping(
        os: {key: "$os", type: String},
        browser: {key: "$browser", type: String},
        device: {key: "$device", type: String},
        referrer: {key: "$referrer", type: String},
        referring_domain: {key: "$referring_domain", type: String}
      )
    end

    struct ResumePacket
      def initialize(token, session_id, seq)
        @op = Discord::Client::OP_RESUME
        @d = ResumePayload.new(token, session_id, seq)
      end

      JSON.mapping(
        op: Int32,
        d: ResumePayload
      )
    end

    # :nodoc:
    struct ResumePayload
      def initialize(@token, @session_id, @seq)
      end

      JSON.mapping(
        token: String,
        session_id: String,
        seq: Int64
      )
    end

    struct StatusUpdatePacket
      def initialize(status, game, afk, since)
        @op = Discord::Client::OP_STATUS_UPDATE
        @d = StatusUpdatePayload.new(status, game, afk, since)
      end

      JSON.mapping(
        op: Int32,
        d: StatusUpdatePayload
      )
    end

    # :nodoc:
    struct StatusUpdatePayload
      def initialize(@status, @game, @afk, @since)
      end

      JSON.mapping(
        status: {type: String?, emit_null: true},
        game: {type: GamePlaying?, emit_null: true},
        afk: Bool,
        since: {type: Int64, nilable: true, emit_null: true}
      )
    end

    struct VoiceStateUpdatePacket
      def initialize(guild_id, channel_id, self_mute, self_deaf)
        @op = Discord::Client::OP_VOICE_STATE_UPDATE
        @d = VoiceStateUpdatePayload.new(guild_id, channel_id, self_mute, self_deaf)
      end

      JSON.mapping(
        op: Int32,
        d: VoiceStateUpdatePayload
      )
    end

    # :nodoc:
    struct VoiceStateUpdatePayload
      def initialize(@guild_id, @channel_id, @self_mute, @self_deaf)
      end

      JSON.mapping(
        guild_id: UInt64,
        channel_id: {type: UInt64?, emit_null: true},
        self_mute: Bool,
        self_deaf: Bool
      )
    end

    struct RequestGuildMembersPacket
      def initialize(guild_id, query, limit)
        @op = Discord::Client::OP_REQUEST_GUILD_MEMBERS
        @d = RequestGuildMembersPayload.new(guild_id, query, limit)
      end

      JSON.mapping(
        op: Int32,
        d: RequestGuildMembersPayload
      )
    end

    # :nodoc:
    struct RequestGuildMembersPayload
      def initialize(@guild_id, @query, @limit)
      end

      JSON.mapping(
        guild_id: UInt64,
        query: String,
        limit: Int32
      )
    end

    struct HelloPayload
      JSON.mapping(
        heartbeat_interval: UInt32,
        _trace: Array(String)
      )
    end

    # This one is special from simply Guild since it also has fields for members
    # and presences.
    struct GuildCreatePayload
      JSON.mapping(
        id: {type: UInt64, converter: SnowflakeConverter},
        name: String,
        icon: String?,
        splash: String?,
        owner_id: {type: UInt64, converter: SnowflakeConverter},
        region: String,
        afk_channel_id: {type: UInt64?, converter: MaybeSnowflakeConverter},
        afk_timeout: Int32?,
        verification_level: UInt8,
        roles: Array(Role),
        emoji: {type: Array(Emoji), key: "emojis"},
        features: Array(String),
        large: Bool,
        voice_states: Array(VoiceState),
        unavailable: Bool?,
        member_count: Int32,
        members: Array(GuildMember),
        channels: Array(Channel),
        presences: Array(Presence),
        widget_channel_id: {type: UInt64?, converter: MaybeSnowflakeConverter},
        default_message_notifications: UInt8,
        explicit_content_filter: UInt8,
        system_channel_id: {type: UInt64?, converter: MaybeSnowflakeConverter}
      )

      {% unless flag?(:correct_english) %}
        def emojis
          emoji
        end
      {% end %}
    end

    struct GuildDeletePayload
      JSON.mapping(
        id: {type: UInt64, converter: SnowflakeConverter},
        unavailable: Bool?
      )
    end

    struct GuildBanPayload
      JSON.mapping(
        username: String,
        id: {type: UInt64, converter: SnowflakeConverter},
        discriminator: String,
        avatar: String,
        bot: Bool?,
        guild_id: {type: UInt64, converter: SnowflakeConverter}
      )
    end

    struct GuildEmojiUpdatePayload
      JSON.mapping(
        guild_id: {type: UInt64, converter: SnowflakeConverter},
        emoji: {type: Array(Emoji), key: "emojis"}
      )

      {% unless flag?(:correct_english) %}
        def emojis
          emoji
        end
      {% end %}
    end

    struct GuildIntegrationsUpdatePayload
      JSON.mapping(
        guild_id: {type: UInt64, converter: SnowflakeConverter}
      )
    end

    struct GuildMemberAddPayload
      JSON.mapping(
        user: User,
        nick: String?,
        roles: {type: Array(UInt64), converter: SnowflakeArrayConverter},
        joined_at: {type: Time?, converter: DATE_FORMAT},
        deaf: Bool,
        mute: Bool,
        guild_id: {type: UInt64, converter: SnowflakeConverter}
      )
    end

    struct GuildMemberUpdatePayload
      JSON.mapping(
        user: User,
        roles: {type: Array(UInt64), converter: SnowflakeArrayConverter},
        nick: {type: String, nilable: true},
        guild_id: {type: UInt64, converter: SnowflakeConverter}
      )
    end

    struct GuildMemberRemovePayload
      JSON.mapping(
        user: User,
        guild_id: {type: UInt64, converter: SnowflakeConverter}
      )
    end

    struct GuildMembersChunkPayload
      JSON.mapping(
        guild_id: {type: UInt64, converter: SnowflakeConverter},
        members: Array(GuildMember)
      )
    end

    struct GuildRolePayload
      JSON.mapping(
        guild_id: {type: UInt64, converter: SnowflakeConverter},
        role: Role
      )
    end

    struct GuildRoleDeletePayload
      JSON.mapping(
        guild_id: {type: UInt64, converter: SnowflakeConverter},
        role_id: {type: UInt64, converter: SnowflakeConverter}
      )
    end

    struct MessageReactionPayload
      JSON.mapping(
        user_id: {type: UInt64, converter: SnowflakeConverter},
        channel_id: {type: UInt64, converter: SnowflakeConverter},
        message_id: {type: UInt64, converter: SnowflakeConverter},
        emoji: ReactionEmoji
      )
    end

    struct MessageReactionRemoveAllPayload
      JSON.mapping(
        channel_id: {type: UInt64, converter: SnowflakeConverter},
        message_id: {type: UInt64, converter: SnowflakeConverter}
      )
    end

    struct MessageUpdatePayload
      JSON.mapping(
        type: UInt8?,
        content: String?,
        id: {type: UInt64, converter: SnowflakeConverter},
        channel_id: {type: UInt64, converter: SnowflakeConverter},
        author: User?,
        timestamp: {type: Time?, converter: DATE_FORMAT},
        tts: Bool?,
        mention_everyone: Bool?,
        mentions: Array(User)?,
        mention_roles: {type: Array(UInt64)?, converter: SnowflakeArrayConverter},
        attachments: Array(Attachment)?,
        embeds: Array(Embed)?,
        pinned: Bool?
      )
    end

    struct MessageDeletePayload
      JSON.mapping(
        id: {type: UInt64, converter: SnowflakeConverter},
        channel_id: {type: UInt64, converter: SnowflakeConverter}
      )
    end

    struct MessageDeleteBulkPayload
      JSON.mapping(
        ids: {type: Array(UInt64), converter: SnowflakeArrayConverter},
        channel_id: {type: UInt64, converter: SnowflakeConverter}
      )
    end

    struct PresenceUpdatePayload
      JSON.mapping(
        user: PartialUser,
        roles: {type: Array(UInt64), converter: SnowflakeArrayConverter},
        game: GamePlaying?,
        nick: String?,
        guild_id: {type: UInt64, converter: SnowflakeConverter},
        status: String
      )
    end

    struct TypingStartPayload
      JSON.mapping(
        channel_id: {type: UInt64, converter: SnowflakeConverter},
        user_id: {type: UInt64, converter: SnowflakeConverter},
        timestamp: {type: Time, converter: Time::EpochConverter}
      )
    end

    struct VoiceServerUpdatePayload
      JSON.mapping(
        token: String,
        guild_id: {type: UInt64, converter: SnowflakeConverter},
        endpoint: String
      )
    end
  end
end
