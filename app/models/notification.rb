class Notification < ApplicationRecord

  default_scope->{order(created_at: :desc)}

  belongs_to :spot, optional: true
  belongs_to :comment, optional: true
  belongs_to :server, class_name: 'User', foreign_key: 'server_id', optional: true
  belongs_to :host, class_name: 'User', foreign_key: 'host_id', optional: true

end
