class ProjectSerializer
  def initialize(project, include_breakdowns: false)
    @project = project
    @include_breakdowns = include_breakdowns
  end

  def as_json(*)
    payload = {
      id: @project.id,
      name: @project.name,
      project_type: @project.project_type,
      description: @project.description,
      status: @project.status,
      casting_office_id: @project.casting_office_id,
      casting_office_name: @project.casting_office&.name,
      created_by_user_id: @project.created_by_user_id,
      production_company_name: @project.production_company_name,
      union_status: @project.union_status,
      shoot_start_date: @project.shoot_start_date,
      shoot_end_date: @project.shoot_end_date,
      location_summary: @project.location_summary,
      confidential: @project.confidential,
      published_at: @project.published_at,
      created_at: @project.created_at
    }

    if @include_breakdowns
      payload[:breakdowns] = @project.breakdowns.map { |b| BreakdownSerializer.new(b).as_json }
    end

    payload
  end
end
