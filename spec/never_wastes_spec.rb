require 'spec_helper'

describe User do
  describe "validation" do
    describe "uniqueness" do
      let!(:user) { Factory.create :user, name: "test_name", deleted: false, deleted_at: nil }
      context "when the same name user don't already exists" do
        subject { User.new(name: "new user name") }
        it { should be_valid }
      end

      context "when the same name user already exists" do
        subject { User.new(name: user.name) }
        it { should_not be_valid }
      end

      context "when the same name user exists and is deleted" do
        before { user.destroy }
        subject { User.new(name: user.name) }
        it { should be_valid }
      end
    end
  end

  describe 'columns' do
    let!(:user) { Factory.create :user, name: "test_name", deleted: false, deleted_at: nil }
    subject { user }

    context 'when user is not deleted' do
      its(:deleted) { should be_false }
      its(:deleted_at) { should be_nil}
    end

    context 'when user is deleted' do
      before { user.destroy }
      its(:deleted) { should be_true }
      its(:deleted_at) { should_not be_nil }
    end
  end

  describe "soft delete" do
    let!(:user) { Factory.create :user, name: "test_name", deleted: false, deleted_at: nil }

    it "should be successful" do
      expect { user.destroy }.to change(User, :count).by(-1)
    end

    it "delete user *soft*ly" do
      expect { user.destroy }.not_to change(User.unscoped, :count)
    end
  end

  describe "default_scope" do
    context 'when 1 user and 1 deleted user exists' do
      let!(:user) { Factory.create :user, name: "test_name", deleted: false, deleted_at: nil }
      let!(:deleted_user) { Factory.create :user, deleted: true, deleted_at:Time.now }

      subject { User.all }
      it { should have(1).items }
      it { should include(user) }

      describe "able to get deleted user" do
        subject { User.unscoped.where(deleted: true).first }
        it { should == deleted_user }
      end
    end
  end
end
