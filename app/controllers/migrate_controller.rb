


class MigrateForum::MigrateForumController < ::ApplicationController
    requires_plugin MigrateForum::PLUGIN_NAME

    before_action :ensure_migrate_forum_enabled

    def start_migration
        puts "Starting migration..."
        render json: {
            status: 200,
            message: "Migration started"

        }
    end

    def ensure_migration_enabled
        if !SiteSetting.migrate_from_existing_forum
          raise Discourse::NotFound.new("Migration is not enabled")
        end
    end
end