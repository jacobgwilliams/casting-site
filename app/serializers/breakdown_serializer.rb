class BreakdownSerializer
  def initialize(breakdown)
    @breakdown = breakdown
  end

  def as_json(*)
    {
      id: @breakdown.id,
      project_id: @breakdown.project_id,
      project_name: @breakdown.project.name,
      character_name: @breakdown.character_name,
      description: @breakdown.description,
      role_type: @breakdown.role_type,
      billing: @breakdown.billing,
      status: @breakdown.status,
      visibility: @breakdown.visibility,
      number_of_roles: @breakdown.number_of_roles,
      audition_required: @breakdown.audition_required,
      submission_deadline: @breakdown.submission_deadline,
      work_start_date: @breakdown.work_start_date,
      work_end_date: @breakdown.work_end_date,
      compensation_details: @breakdown.compensation_details,
      location_details: @breakdown.location_details,
      published_at: @breakdown.published_at,
      criteria: criteria_json,
      skill_requirements: skill_requirements_json
    }
  end

  private

  def criteria_json
    criterion = @breakdown.breakdown_criterion
    return nil unless criterion

    {
      portrayal_age_min: criterion.portrayal_age_min,
      portrayal_age_max: criterion.portrayal_age_max,
      gender_presentation: criterion.gender_presentation,
      union_requirement: criterion.union_requirement,
      local_hire_required: criterion.local_hire_required,
      required_location: criterion.required_location,
      travel_provided: criterion.travel_provided,
      work_authorization: criterion.work_authorization
    }
  end

  def skill_requirements_json
    @breakdown.breakdown_skill_requirements.includes(:skill).map do |req|
      {
        id: req.id,
        skill_id: req.skill_id,
        skill_name: req.skill.name,
        requirement_level: req.requirement_level,
        minimum_proficiency: req.minimum_proficiency,
        notes: req.notes
      }
    end
  end
end
