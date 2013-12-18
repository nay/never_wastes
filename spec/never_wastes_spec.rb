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

      context "when the same name user exists and is deleted, and the other is going to be deleted, when there is an unique index" do
        before { user.destroy }
        let(:other) { User.create!(name: user.name) }
        it { expect { other.destroy }.not_to raise_error }
      end
    end
  end

  describe 'columns' do
    let!(:user) { Factory.create :user, name: "test_name", deleted: false, deleted_at: nil }
    subject { user }

    context 'when user is not deleted' do
      its(:deleted) { should be_false }
      its(:deleted_at) { should be_nil }
      its(:waste_id) { should eq(0) }
    end

    context 'when user is deleted' do
      before { user.destroy }
      its(:deleted) { should be_true }
      its(:deleted_at) { should_not be_nil }
      its(:waste_id) { should eq(user.id)}
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

  describe ".delete_all_softly" do
    let!(:delete_users) { (1..3).inject([]) { |result, i| result << Factory.create(:user, deleted: false, deleted_at: nil) } }
    let!(:undelete_user) { Factory.create(:user, name: 'undeleted', deleted: false, deleted_at: nil) }

    it "should be successful" do
      expect { User.where(User.arel_table[:name].not_eq('undeleted')).delete_all_softly }.to change(User, :count).by(-3)
    end

    it "should delete users *soft*ly" do
      expect { User.where(User.arel_table[:name].not_eq('undeleted')).delete_all_softly }.not_to change(User.unscoped, :count)
    end

    describe 'after' do
      before do
        User.where(User.arel_table[:name].not_eq('undeleted')).delete_all_softly
      end

      it "should find undeleted users" do
        User.where(User.arel_table[:name].eq('undeleted')).length.should == 1
      end

      describe 'columns' do
        context 'when user is not deleted' do
          subject { undelete_user.reload }
          its(:deleted) { should be_false }
          its(:deleted_at) { should be_nil}
          its(:waste_id) { should eq(0) }
        end

        context 'when user is deleted' do
          subject { delete_users.first.reload }
          its(:deleted) { should be_true }
          its(:deleted_at) { should_not be_nil }
          its(:waste_id) { should eq(delete_users.first.id) }
        end
      end
    end
  end

  describe ".demolish_all" do
    let!(:delete_users) { (1..3).inject([]) { |result, i| result << Factory.create(:user, deleted: false, deleted_at: nil) } }
    let!(:undelete_user) { Factory.create(:user, name: 'undeleted', deleted: false, deleted_at: nil) }
    it "should be successful" do
      expect { User.where(User.arel_table[:name].not_eq('undeleted')).demolish_all }.to change(User, :count).by(-3)
    end

    it "should delete users" do
      expect { User.where(User.arel_table[:name].not_eq('undeleted')).demolish_all }.to change(User.unscoped, :count).by(-3)
    end
  end
end
