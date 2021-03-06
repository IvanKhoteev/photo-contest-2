# frozen_string_literal: true

ActiveAdmin.register Post do
  config.clear_action_items!
  config.per_page = [5, 10, 50, 100]
  permit_params :name, :description

  batch_action I18n.t(:ban) do |ids|
    batch_action_collection.find(ids).each do |post|
      post.ban! :ban unless post.banned?
    end
    redirect_to admin_posts_path
  end

  batch_action I18n.t(:approve) do |ids|
    batch_action_collection.find(ids).each do |post|
      post.approve! :approve unless post.approved?
    end
    redirect_to admin_posts_path
  end

  batch_action :destroy, false

  index do
    selectable_column
    column :title
    column :photo do |post|
      image_tag post.photo.admin.url
    end
    column :aasm_state
    column :moderation do |post|
      columns do
        if post.moderated?
          column do
            link_to :approve, approve_admin_post_path(post), class: 'button2'
          end
          column do
            link_to :ban, ban_admin_post_path(post), class: 'button1'
          end
        end
      end
    end
    actions
  end

  show do
    attributes_table do
      row :photo do |ad|
        image_tag ad.photo.show.url
      end
      row :title
      row :description
      row :author, :user_id do
        link_to(post.user.full_name, post.user)
      end
      row :created_at
      row :updated_at
      row :id
      row :aasm_state
    end
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :description
    end
    f.actions
  end

  member_action :approve do
    post.approve!
    redirect_to admin_posts_path
  end

  member_action :ban do
    post.ban!
    redirect_to admin_posts_path
  end

  member_action :restore do
    resource.restore!
    redirect_to admin_posts_path
  end
end
