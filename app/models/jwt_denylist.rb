class JwtDenylist < ApplicationRecord
    self.table_name = 'jwt_denylist'
    include Devise::JWT::RevocationStrategies::Denylist
end
