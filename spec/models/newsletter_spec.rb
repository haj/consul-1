require 'rails_helper'

describe Newsletter do
  let(:newsletter) { build(:newsletter) }

  it "is valid" do
    expect(newsletter).to be_valid
  end

  it 'is not valid without a subject' do
    newsletter.subject = nil
    expect(newsletter).to_not be_valid
  end

  it 'is not valid without a to' do
    newsletter.to = nil
    expect(newsletter).to_not be_valid
  end

  it 'is not valid without a from' do
    newsletter.from = nil
    expect(newsletter).to_not be_valid
  end

  it 'is not valid without a body' do
    newsletter.body = nil
    expect(newsletter).to_not be_valid
  end

  pending "Validate to attribute email format"
  pending "Validate frm attribute email format"

  context "User Groups" do

    describe "#all_users" do
      it "returns all active users with newsletter enabled" do
        active_user1 = create(:user, newsletter: true)
        active_user2 = create(:user, newsletter: true)
        active_user3 = create(:user, newsletter: false)
        erased_user  = create(:user, erased_at: Time.current)

        expect(Newsletter.all_users).to include active_user1
        expect(Newsletter.all_users).to include active_user2
        expect(Newsletter.all_users).to_not include active_user3
        expect(Newsletter.all_users).to_not include erased_user
      end
    end

    describe "#proposal_authors" do
      it "returns users that have created a proposal" do
        user1 = create(:user)
        user2 = create(:user)

        proposal = create(:proposal, author: user1)

        proposal_authors = Newsletter.proposal_authors
        expect(proposal_authors).to include user1
        expect(proposal_authors).to_not include user2
      end
    end

    describe "#current_budget_investment_authors" do
      it "returns users that have created a budget investment" do
        user1 = create(:user)
        user2 = create(:user)

        investment = create(:budget_investment, author: user1)

        investment_authors = Newsletter.investment_authors
        expect(investment_authors).to include user1
        expect(investment_authors).to_not include user2
      end
    end

    describe "#feasible_and_undecided_investment_authors" do
      it "returns authors of a feasible or an undecided budget investment" do
        user1 = create(:user)
        user2 = create(:user)
        user3 = create(:user)

        investment1 = create(:budget_investment, :feasible, author: user1)
        investment2 = create(:budget_investment, :undecided, author: user2)
        investment3 = create(:budget_investment, :unfeasible, author: user3)

        investment_authors = Newsletter.feasible_and_undecided_investment_authors
        expect(investment_authors).to include user1
        expect(investment_authors).to include user2
        expect(investment_authors).to_not include user3
      end
    end

    describe "#selected_investment_authors" do
      it "returns authors of selected budget investments", :focus do
        user1 = create(:user)
        user2 = create(:user)

        investment1 = create(:budget_investment, :selected, author: user1)
        investment2 = create(:budget_investment, :unselected, author: user2)
        budget = create(:budget)
        investment1.update(budget: budget)
        investment2.update(budget: budget)

        investment_authors = Newsletter.selected_investment_authors
        expect(investment_authors).to include user1
        expect(investment_authors).to_not include user2
      end
    end

    describe "#winner_investment_authors" do
    end

    pending "test that users are not duplicate..."
    pending "test that only current budget investments are returned"
  end
end
