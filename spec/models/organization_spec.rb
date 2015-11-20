require "rails_helper"

describe Organization, :type => :model do
  describe "schema" do
    it { should have_db_column(:name).of_type(:string) }
  end

  describe "relationships" do
    it { should have_many(:members).through(:organization_memberships) }
    it { should have_many(:projects) }
    it { should have_many(:teams) }
  end

  describe "instance methods" do
    describe "#admins" do
      it "should return users with membership role 'admin'" do
        organization = create(:organization)
        create_list(:organization_membership, 10, role: "admin", organization: organization)
        create_list(:organization_membership, 10, role: "regular", organization: organization)

        organization.reload

        expect(organization.admins.length).to eq 10
        expect(organization.members.length).to eq 20

        expect(organization.admins.all? { |admin| admin.class == User }).to be true
      end
    end
  end
end