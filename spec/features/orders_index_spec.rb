require "rails_helper"

feature "order index page" do
  scenario "user views order attributes" do
    order = create(:order)
    state_name = OrderDecorator.state_by_abbr(order.address_state)

    visit admin_orders_path

    expect(page).to have_header("Orders")
    expect(page).to have_content(order.id)
    expect(state_name.length > order.address_state.length).to be_truthy
    expect(page).to have_content(state_name)
  end

  scenario "user clicks through to customer show page" do
    order = create(:order)

    visit admin_orders_path
    click_on(displayed(order.customer))

    expect(page).to have_header(order.customer.name)
  end

  scenario "user clicks through to the order show page", :js do
    order = create(:order)

    visit admin_orders_path
    click_row_for(order)

    expect(page).to have_header(displayed(order))
    expect(page).to have_link(order.customer.name)
  end

  scenario "user clicks through to the edit page" do
    order = create(:order)

    visit admin_orders_path
    click_on t("administrate.actions.edit")

    expect(current_path).to eq(edit_admin_order_path(order))
  end

  scenario "user clicks through to the new page" do
    visit admin_orders_path
    click_on("New order")

    expect(current_path).to eq(new_admin_order_path)
  end

  scenario "user deletes record", js: true do
    create(:order)

    visit admin_orders_path
    accept_confirm do
      click_on t("administrate.actions.destroy")
    end
    expect(page).to have_flash(
      t("administrate.controller.destroy.success", resource: "Order")
    )
  end

  scenario "cannot delete because associated payment", js: true do
    create(:payment, order: create(:order))

    visit admin_orders_path
    accept_confirm do
      click_on t("administrate.actions.destroy")
    end
    expect(page).to have_flash(
      "Cannot delete record because dependent payments exist", type: :error
    )
  end
end
