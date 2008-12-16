require File.dirname(__FILE__) + '/../../test_helper'

##
# Here we test habtm, hm, polimorphism, relate and unrelate.
#
class Admin::AssetsControllerTest < ActionController::TestCase

  def setup
    typus_user = typus_users(:admin)
    @request.session[:typus] = typus_user.id
  end

  ##
  # A page has many assets, and the relationship is polymorphic.
  #
  def test_should_test_polymorphic_relationship_message

    page = pages(:published)
    assert_equal 2, page.assets.size

    get :new, { :back_to => "/admin/pages/#{page.id}/edit", :resource => page.class.name, :resource_id => page.id }
    assert_match "You're adding a new Asset to a Page. Do you want to cancel it?", @response.body

  end

  def test_should_create_a_polymorphic_relationship

    page = pages(:published)
    assert_equal 2, page.assets.size

    post :create, { :back_to => "/admin/pages/#{page.id}/edit", :resource => page.class.name, :resource_id => page.id }
    assert_response :redirect
    assert_redirected_to '/admin/pages/1/edit'

    assert_equal 3, page.assets.size
    assert flash[:success]
    assert_equal "Asset successfully assigned to Page.", flash[:success]

  end

  def test_should_unrelate_a_polymorphic_relationship

    page = pages(:published)
    assert_equal 2, page.assets.size

    @request.env["HTTP_REFERER"] = "/admin/pages/#{page.id}/edit"

    get :unrelate, { :id => page.assets.first.id, :model => page.class.name, :model_id => page.id }
    assert_response :redirect
    assert_redirected_to @request.env["HTTP_REFERER"]
    assert flash[:success]
    assert_match "Asset removed from Page.", flash[:success]

    assert_equal 1, page.assets.size

  end

end