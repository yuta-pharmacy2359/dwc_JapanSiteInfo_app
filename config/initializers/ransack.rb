Ransack.configure do |config|

  config.add_predicate 'to_age_lt',
    arel_predicate: 'gteq',
    formatter: -> (v) { (v.years.ago + 1.day).to_date },
    type: :integer,
    compounds: false

  config.add_predicate 'to_age_gteq',
    arel_predicate: 'lteq',
    formatter: -> (v) { v.years.ago.to_date },
    type: :integer,
    compounds: false

end
