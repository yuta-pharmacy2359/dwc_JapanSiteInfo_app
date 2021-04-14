FactoryBot.define do
  factory :notification do
    spot_id { '1' }
    server_id { '2' }
    host_id { '1' }
    kind { 'favorite' }

    factory :notification2 do
      comment_id { '1' }
      kind { 'comment' }
    end

    factory :notification3 do
      kind { 'follow' }
    end
  end
end