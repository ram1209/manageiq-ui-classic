class TreeBuilderAlertProfileObj < TreeBuilder
  def initialize(name, type, sandbox, build = true, assign_to = nil, cat = nil, objects = nil)
    @assign_to = assign_to
    @cat = cat
    @objects = objects
    build = false unless @assign_to
    super(name, type, sandbox, build)
  end

  def override(node, object, _pid, _options)
    identifier = (object.name.presence || object.description)
    if object.kind_of?(MiddlewareServer)
      identifier += "-" + object.hostname
    end

    if @assign_to.ends_with?("-tags")
      node[:icon] = "fa fa-tag"
    elsif @assign_to == "tenant"
      node[:icon] = "pficon pficon-tenant"
    else
      node[:image] = ActionController::Base.helpers.image_path("100/#{@assign_to}.png")
    end

    node[:title] = identifier
    node[:cfmeNoClick] = true
    node[:hideCheckbox] = false
    node[:select] = @objects.include?(object.id)
    node
  end

  def tree_init_options(_tree_name)
    {
      :expand => true
    }
  end

  def set_locals_for_render
    locals = super
    locals.merge!(
      :id_prefix  => "obj_treebox2",
      :oncheck    => "miqOnCheckHandler",
      :check_url  => "alert_profile_assign_changed/",
      :checkboxes => true,
    )
  end

  def root_options
    t = @assign_to.ends_with?("-tags") ? "Tags" : ui_lookup(:tables => @assign_to)
    {
      :title        => t,
      :tooltip      => "",
      :icon         => "pficon pficon-folder-open",
      :hideCheckbox => true,
      :cfmeNoClick  => true,
      :expand       => true
    }
  end

  def x_get_tree_roots(count_only, _options)
    obj = if !@assign_to || @assign_to == "enterprise"
                 []
               elsif @assign_to.ends_with?("-tags")
                 @cat ? Classification.find(@cat).entries : []
               else
                 @assign_to.camelize.constantize.all
               end

    count_only_or_objects(count_only, obj.sort_by { |o| (o.name.presence || o.description).downcase })
  end
end
