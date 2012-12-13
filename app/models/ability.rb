class Ability
  include CanCan::Ability

  def initialize(user)
    unless user.nil?
      # this permission gives access to all the admin functions
      if user.global_role.can_edit_system_configuration
        can :manage, User
        can :manage, CourseRole
        can :manage, GlobalRole
        can :manage, Institution
      end

      if user.global_role.can_manage_all_courses
        can :manage, CourseOffering
      end

      # everyone can read course offerings
      can :read, CourseOffering

      # a person with create access can create courses, of course
      if user.global_role.can_create_courses
        can :create, CourseOffering
      end

      # in all other cases, the ability to manage a course depends on the user's
      # individual course role
      can :manage, CourseOffering do |course|
        enrollement = CourseEnrollments.where(:user_id => user.id,
                                              :course_id => course.id).first
        enrollement.course_role.can_manage_course
      end
      # # the user can only update themself
      # can :update, User do |target_user|
      #   target_user == user

    end

    
    # if user.global_role.can_manage_all_courses
    #   can :manage, :

    #   # the user can read CourseOfferings WHERE the students table 
    #   # contains that student's user id
    #   can :read, CourseOffering, :students => { :id => user.id }
    #   can :read, CourseOffering, :staff => { :id => user.id }
    #   can :manage, CourseOffering, :staff => { :id => user.id },
    #     :course_offering_staff => { :manager => true }
    # end

    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user permission to do.
    # If you pass :manage it will apply to every action. Other common actions here are
    # :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. If you pass
    # :all it will apply to every resource. Otherwise pass a Ruby class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end
