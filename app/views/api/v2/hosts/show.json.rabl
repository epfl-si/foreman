object @host

extends "api/v2/hosts/main"

child :interfaces => :interfaces do
  extends "api/v2/interfaces/main"
end

child :puppetclasses do
  extends "api/v2/puppetclasses/base"
end

node do |host|
  { :all_puppetclasses => partial("api/v2/puppetclasses/base", :object => host.all_puppetclasses) }
end

child :config_groups do
  extends "api/v2/config_groups/main"
end

root_object.facet_definitions.each do |definition|
  next unless definition.api_single_view
  node(false, if: ->(host) { definition.facet_record_for(host) }) do |host|
    partial(definition.api_single_view, object: host, locals: { facet: definition.facet_record_for(host) })
  end
end

node :permissions do |host|
  authorizer = Authorizer.new(User.current)
  Permission.where(:resource_type => "Host").all.each_with_object({}) do |permission, hash|
    hash[permission.name] = authorizer.can?(permission.name, host, false)
  end
end
