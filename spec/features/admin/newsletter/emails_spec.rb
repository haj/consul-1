require 'rails_helper'

feature "Admin newsletter emails" do

  background do
    admin = create(:administrator)
    login_as(admin.user)
  end

  scenario "Show" do
    newsletter = create(:newsletter, subject: "This is a subject",
                                     to: "user@example.com",
                                     from: "noreply@consul.dev",
                                     body: "This is a body")

    visit admin_newsletter_path(newsletter)

    expect(page).to have_content "This is a subject"
    expect(page).to have_content "user@example.com"
    expect(page).to have_content "noreply@consul.dev"
    expect(page).to have_content "This is a body"
  end

  scenario "Index" do
    3.times { create(:newsletter) }

    visit admin_newsletters_path

    expect(page).to have_css(".newsletter", count: 3)

    Newsletter.all.each do |newsletter|
      within("#newsletter_#{newsletter.id}") do
        expect(page).to have_content newsletter.subject
        expect(page).to have_content newsletter.to
      end
    end
  end

  scenario "Create" do
    visit admin_newsletters_path
    click_link "New newsletter"

    fill_in "newsletter_subject", with: "This is a subject"
    fill_in "newsletter_to", with: "user1@example.com"
    fill_in "newsletter_from", with: "noreply@consul.dev"
    fill_in "newsletter_body", with: "This is a body"
    click_button "Create Newsletter"

    expect(page).to have_content "Newsletter created successfully"
    expect(page).to have_content "This is a subject"
    expect(page).to have_content "user1@example.com"
    expect(page).to have_content "noreply@consul.dev"
    expect(page).to have_content "This is a body"
  end

  scenario "Update" do
    newsletter = create(:newsletter)

    visit admin_newsletter_path(newsletter)
    click_link "Edit"

    fill_in "newsletter_subject", with: "This is a different subject"
    fill_in "newsletter_to", with: "user39@example.com"
    fill_in "newsletter_from", with: "no-reply@consul.dev"
    fill_in "newsletter_body", with: "This is different a body"
    click_button "Update Newsletter"

    expect(page).to have_content "Newsletter updated successfully"
    expect(page).to have_content "This is a different subject"
    expect(page).to have_content "user39@example.com"
    expect(page).to have_content "no-reply@consul.dev"
    expect(page).to have_content "This is different a body"
  end

  scenario "Destroy" do
    newsletter = create(:newsletter)

    visit admin_newsletter_path(newsletter)
    click_link "Delete"

    expect(page).to have_content "Newsletter deleted successfully"
    expect(page).to have_css(".newsletter", count: 0)
  end

  scenario 'Errors on create' do
    visit new_admin_newsletter_path

    click_button "Create Newsletter"

    expect(page).to have_content error_message
  end

  scenario "Errors on update" do
    newsletter = create(:newsletter)
    visit edit_admin_newsletter_path(newsletter)

    fill_in "newsletter_subject", with: ""
    click_button "Update Newsletter"

    expect(page).to have_content error_message
  end

  scenario "Send newsletter email" do
    newsletter = create(:newsletter)
    visit admin_newsletter_path(newsletter)

    click_link "Send"

    expect(page).to have_content "Newsletter sent successfully"
  end

  scenario "Select list of users to send newsletter" do
    Newsletter::USER_GROUPS.each do |user_group|
      visit new_admin_newsletter_path

      fill_in_newsletter_form
      select user_group, from: 'newsletter_to'
      click_button "Create Newsletter"

      expect(page).to have_content(user_group)
    end
  end
end
