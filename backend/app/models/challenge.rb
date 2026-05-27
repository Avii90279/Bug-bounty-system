class Challenge < ApplicationRecord
  DIFFICULTIES = { easy: 0, medium: 1, hard: 2, expert: 3 }.freeze
  LANGUAGES = {
    javascript: 0, python: 1, ruby: 2, java: 3, cpp: 4, go: 5, rust: 6, typescript: 7
  }.freeze

  enum difficulty: DIFFICULTIES
  enum language: LANGUAGES

  belongs_to :created_by, class_name: "User", optional: true
  has_many :submissions, dependent: :destroy
  has_many :hints, -> { order(:level) }, dependent: :destroy
  has_many :rooms, dependent: :nullify

  validates :title, :buggy_code, presence: true
  validates :difficulty, :language, presence: true

  scope :by_difficulty, ->(d) { where(difficulty: d) if d.present? }
  scope :by_language, ->(l) { where(language: l) if l.present? }
  scope :recent, -> { order(created_at: :desc) }

  def difficulty_multiplier
    { "easy" => 1.0, "medium" => 1.5, "hard" => 2.0, "expert" => 3.0 }[difficulty] || 1.0
  end

  def monaco_language
    language.to_s == "cpp" ? "cpp" : language.to_s
  end

  def record_attempt!
    increment!(:attempts_count)
  end

  def record_solve!(time_seconds)
    increment!(:solves_count)
    if avg_solve_time.nil?
      update!(avg_solve_time: time_seconds)
    else
      new_avg = ((avg_solve_time * (solves_count - 1)) + time_seconds) / solves_count.to_f
      update!(avg_solve_time: new_avg.round(1))
    end
  end

  def analytics
    {
      attempts: attempts_count,
      solves: solves_count,
      solve_rate: attempts_count.positive? ? (solves_count.to_f / attempts_count * 100).round(1) : 0,
      avg_solve_time: avg_solve_time,
      difficulty: difficulty,
      language: language
    }
  end
end
