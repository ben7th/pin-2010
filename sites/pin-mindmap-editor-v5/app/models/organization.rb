class Organization < OrganizationBase
  index :email
  has_many :members,:foreign_key => "organization_id"
end