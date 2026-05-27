class BadgeSerializer
  def initialize(badge)
    @badge = badge
  end

  def as_json
    {
      id: @badge.id,
      name: @badge.name,
      slug: @badge.slug,
      description: @badge.description,
      icon: @badge.icon,
      nft_eligible: @badge.nft_eligible,
      criteria_type: @badge.criteria_type,
      criteria_value: @badge.criteria_value
    }
  end
end
