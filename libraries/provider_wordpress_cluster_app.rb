require 'chef/provider/lwrp_base'

class Chef
  class Provider
    class WordpressClusterApp < Chef::Provider::LWRPBase
      include Chef::DSL::IncludeRecipe
      use_inline_resources if defined?(use_inline_resources)

      def whyrun_supported?
        true
      end

      action :create do
        capistrano_user 'deploy' do
          group 'deploy'
          group_id 3000
        end

        include_recipe 'capistrano-base::ssh'

        capistrano_wordpress_app new_resource.app_name do
          deploy_root "/var/www/#{new_resource.app_name}"
          docroot "/var/www/#{new_resource.app_name}/current/web"
          deployment_user 'deploy'
          deployment_group 'deploy'
          server_name new_resource.server_name
        end

        capistrano_shared_file '.env.ctmpl' do
          template '.env.ctmpl.erb'
          deploy_root "/var/www/#{new_resource.app_name}"
          owner 'deploy'
          group 'deploy'
        end

        include_recipe 'consul::default'
        include_recipe 'consul-services::apache2'
        include_recipe 'consul-services::consul-template'

        node.normal['consul_template'] = {
          consul: '127.0.0.1:8500'
        }

        include_recipe 'consul-template::default'

        consul_template_config "#{new_resource.app_name}_env" do
          templates [{
            source: "/var/www/#{new_resource.app_name}/shared/.env.ctmpl",
            destination: "/var/www/#{new_resource.app_name}/shared/.env"
          }]
        end
      end

      action :delete do
        capistrano_user 'deploy' do
          action :delete
        end

        capistrano_wordpress_app new_resource.app_name do
          deploy_root "/var/www/#{new_resource.app_name}"
          action :delete
        end

        capistrano_shared_file '.env.ctmpl' do
          deploy_root "/var/www/#{new_resource.app_name}"
          action :delete
        end
      end
    end
  end
end