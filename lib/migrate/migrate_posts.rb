


class MigratePosts::Passport

    def migrate_posts
        puts "Migrating posts..."
        migrate_posts = MigratePosts::MigratePosts.new
        migrate_posts.migrate_posts
    end

end