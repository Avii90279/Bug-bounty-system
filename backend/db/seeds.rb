puts "Seeding Bug Bounty Platform..."

admin = User.find_or_create_by!(email: "admin@bugbounty.dev") do |u|
  u.username = "admin"
  u.password = "Admin123!Secure"
  u.role = :admin
  u.xp = 10_000
  u.score = 50_000
end

badges_data = [
  { name: "First Blood", slug: "first-blood", description: "Solve your first challenge", criteria_type: :solves_count, criteria_value: 1, icon: "🩸" },
  { name: "Bug Hunter", slug: "bug-hunter", description: "Solve 10 challenges", criteria_type: :solves_count, criteria_value: 10, icon: "🐛" },
  { name: "Elite Hacker", slug: "elite-hacker", description: "Solve 50 challenges", criteria_type: :solves_count, criteria_value: 50, icon: "⚡", nft_eligible: true },
  { name: "Speed Demon", slug: "speed-demon", description: "Solve under 60 seconds", criteria_type: :fast_solve, criteria_value: 60, icon: "🏎️" },
  { name: "No Hints", slug: "no-hints", description: "Solve 5 without hints", criteria_type: :no_hints_streak, criteria_value: 5, icon: "🧠" },
  { name: "Polyglot", slug: "polyglot", description: "Solve in 3 languages", criteria_type: :languages_solved, criteria_value: 3, icon: "🌐", nft_eligible: true }
]

badges_data.each do |attrs|
  Badge.find_or_create_by!(slug: attrs[:slug]) { |b| b.assign_attributes(attrs) }
end

sample_challenges = [
  {
    title: "Off-by-One Buffer",
    description: "Fix the array bounds check in this C-style loop.",
    difficulty: :easy,
    language: :javascript,
    buggy_code: <<~JS,
      function sumArray(arr, n) {
        let total = 0;
        for (let i = 0; i <= n; i++) {
          total += arr[i];
        }
        return total;
      }
      module.exports = sumArray;
    JS
    solution_code: "for (let i = 0; i < n; i++)",
    test_cases: [{ input: { arr: [1, 2, 3], n: 3 }, expected: 6 }],
    xp_reward: 50,
    base_score: 500
  },
  {
    title: "SQL Injection Gateway",
    description: "Patch the vulnerable query builder.",
    difficulty: :medium,
    language: :python,
    buggy_code: <<~PY,
      def get_user(db, user_id):
          query = f"SELECT * FROM users WHERE id = {user_id}"
          return db.execute(query)
    PY
    test_cases: [{ input: { user_id: "1 OR 1=1" }, expected: "parameterized" }],
    xp_reward: 150,
    base_score: 1200
  },
  {
    title: "Race Condition Cache",
    description: "Fix the concurrent cache update bug.",
    difficulty: :hard,
    language: :ruby,
    buggy_code: <<~RUBY,
      class Cache
        def initialize
          @store = {}
        end
        def fetch(key)
          return @store[key] if @store[key]
          value = expensive_compute(key)
          @store[key] = value
          value
        end
      end
    RUBY
    xp_reward: 300,
    base_score: 2000
  }
]

sample_challenges.each do |attrs|
  challenge = Challenge.find_or_create_by!(title: attrs[:title]) do |c|
    c.assign_attributes(attrs.merge(ai_generated: false, created_by: admin))
  end
  next if challenge.hints.any?

  [
    { level: 1, content: "Check loop boundary conditions.", score_penalty: 50 },
    { level: 2, content: "The comparison operator may be inclusive when it shouldn't be.", score_penalty: 100 },
    { level: 3, content: "Use `<` instead of `<=` for array length.", score_penalty: 150 }
  ].each do |hint_attrs|
    challenge.hints.find_or_create_by!(level: hint_attrs[:level]) do |h|
      h.content = hint_attrs[:content]
      h.score_penalty = hint_attrs[:score_penalty]
    end
  end
end

puts "Seeded #{User.count} users, #{Badge.count} badges, #{Challenge.count} challenges"
