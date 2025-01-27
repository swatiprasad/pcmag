module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /the home\s?page/
      '/'

    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    when /my profile page/i
      "/people/#{@user.friendly_id}"

    when /the submit page/i
      "/submit"

    when /the magazine's cover page/i
      "/magazines/#{Magazine.first}/#{Page.where(position: 1).first.to_param}"

    when /the first (.*) page/i
      model = $1.titleize.constantize
      instance = if model.count > 0
                   model.first
                 else
                   Factory.create(model.to_s.underscore.to_sym)
                 end
      eval "#{model.base_class.to_s.underscore}_path('#{instance.to_param}')"

    when /the "([^"]*)" magazine page/i
      param = $1.parameterize
      eval "magazine_path('#{$1.parameterize}')"

    else
      begin
        page_name =~ /the (.*) page/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue Object => e
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)
