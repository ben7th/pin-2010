class Organization < OrganizationBase
  has_many :members,:foreign_key => "organization_id"
end