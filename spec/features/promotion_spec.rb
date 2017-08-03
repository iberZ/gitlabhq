require 'spec_helper'

describe 'Promotions', js: true do
  let(:admin) { create(:admin) }
  let(:user) { create(:user) }
  let(:developer) { create(:user) }
  let(:project) { create(:empty_project, path: 'gitlab', name: 'sample') }

  describe 'no promotion shown at all if you have a license', js: true do
    sign_in(user)
    project.team << [user, :master]
    visit edit_project_path(project)
    expect(page).not_to have_selector('#promote_service_desk')
  end

  describe 'for project features in general on premise', js: true do
    before do
      allow(License).to receive(:current).and_return(nil)

      sign_in(user)
      project.team << [user, :master]
    end

    it 'should have the contact admin line' do
      expect(find('#promote_service_desk')).to have_content 'Contact your Administrator to upgrade your license.'
    end
    
    it 'should have the start trial button' do
      sign_in(admin)
      visit edit_project_path(project)
      expect(find('#promote_service_desk')).to have_content 'Start GitLab Enterprise Edition trial'
    end
  end

  describe 'for project features in general for .com', js: true do
    before do
      allow(Gitlab).to receive(:com?).and_return(true)
    end

    it 'should have the Upgrade your plan button' do
      sign_in(user)
      project.team << [user, :master]

      expect(find('#promote_service_desk')).to have_content 'Upgrade your plan'
    end

    it 'should have the contact owner line' do
      sign_in(developer)
      project.team << [developer, :developer]

      expect(find('#promote_service_desk')).to have_content 'Upgrade your plan'
    end
  end  

  describe 'for service desk', js: true do
    before do
      sign_in(user)
      project.team << [user, :master]
    end

    it 'should appear in project edit page' do
      visit edit_project_path(project)
      expect(find('#promote_service_desk')).to have_content 'Improve customer support with GitLab Service Desk.'
      expect(find('#promote_service_desk')).to have_content 'GitLab Service Desk is a simple way to allow people to create issues in your GitLab instance without needing their own user account.'
    end

    it 'does not show when cookie is set' do
      visit edit_project_path(project)

      within('#promote_service_desk') do
        find('.close').trigger('click')
      end

      visit edit_project_path(project)

      expect(page).not_to have_selector('#promote_service_desk')
    end
  end
end
