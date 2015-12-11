require 'rails_helper'

RSpec.describe PostImage, type: :model do
  let(:gif_string) {
    file = File.open("#{Rails.root}/spec/sample_data/base64_images/gif.txt", 'r')
    open(file) { |io| io.read }
  }

  let(:jpeg_without_data_string) {
    file = File.open("#{Rails.root}/spec/sample_data/base64_images/jpeg_without_data_string.txt", 'r')
    open(file) { |io| io.read }
  }

  describe "schema" do
    it { should have_db_column(:user_id).of_type(:integer).with_options(null: false) }
    it { should have_db_column(:post_id).of_type(:integer).with_options(null: false) }
    it { should have_db_column(:filename).of_type(:text).with_options(null: false) }
    it { should have_db_column(:base64_photo_data).of_type(:text).with_options(null: false) }
    it { should have_db_column(:updated_at) }
    it { should have_db_column(:created_at) }
  end

  describe "relationships" do
    it { should belong_to(:user) }
    it { should belong_to(:post) }
  end

  describe "validations" do
    it { should validate_presence_of(:user) }
    it { should validate_presence_of(:post) }
    it { should validate_presence_of(:filename) }
    it { should validate_presence_of(:base64_photo_data) }

    it { should allow_value(gif_string).for(:base64_photo_data) }
    it { should_not allow_value(jpeg_without_data_string).for(:base64_photo_data) }
  end

  context 'paperclip' do
    context 'without cloudfront' do
      it { should have_attached_file(:image) }
      it { should validate_attachment_content_type(:image)
          .allowing('image/png', 'image/gif', 'image/jpeg')
          .rejecting('text/plain', 'text/xml') }
    end

    context 'with cloudfront'  do
      let(:post) { create(:post, id: 1) }
      let(:post_image) { create(:post_image, :with_s3_image, id: 1, post: post, filename: "default-avatar.png", base64_photo_data: gif_string) }

      it 'should have cloudfront in the URL', vcr: { cassette_name: 'models/post_image/aws-upload' } do
        post_image.decode_image_data
        expect(post_image.image.url(:thumb)).to include 'cloudfront'
      end

      it 'should have the right path', vcr: { cassette_name: 'models/post_image/aws-upload' } do
        post_image.decode_image_data
        expect(post_image.image.url(:thumb)).to include "posts/#{post.id}/images/#{post_image.id}"
      end
    end
  end
end
