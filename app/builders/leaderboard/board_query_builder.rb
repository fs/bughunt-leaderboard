module Leaderboard
  class BoardQueryBuilder
    def initialize(limit, offset)
      @limit = limit
      @offset = offset
    end

    def build
      %Q(
        SELECT
          summary.username AS "Username",
          #{challenge_totals},
          sum(summary.points) AS "Total"
        FROM users_with_points summary
        GROUP BY username
        ORDER BY sum(summary.points) DESC
        LIMIT #{@limit}
        OFFSET #{@offset}
      )
    end

    private

    def challenge_totals
      challenges.map do |challenge|
        %Q(
          COALESCE(
            SUM(CASE WHEN summary.challenge_id = #{challenge.first} THEN summary.points ELSE null END), '-'
          ) AS "#{challenge.second}"
        )
      end.join(",")
    end

    def challenges
      Leaderboard::ChallengeQuery.new.call.entries
    end
  end
end