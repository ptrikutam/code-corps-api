# == Schema Information
#
# Table name: skills
#
#  id                :integer          not null, primary key
#  title             :string           not null
#  description       :string
#  skill_category_id :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class SkillSerializer < ActiveModel::Serializer
  attributes :id, :title, :description

  belongs_to :skill_category
end
