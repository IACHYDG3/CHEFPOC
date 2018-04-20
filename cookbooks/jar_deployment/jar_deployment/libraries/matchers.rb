if defined?(ChefSpec)
  def deploy_jar_deployment(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(
      :jar_deployment,
      :deploy,
      resource_name)
  end

  def delete_jar_deployment(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(
      :jar_deployment,
      :delete,
      resource_name)
  end
end
