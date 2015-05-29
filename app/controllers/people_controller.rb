class PeopleController < ApplicationController
  before_action :set_person, only: [:show, :edit, :update, :destroy]

  # GET /people
  # GET /people.json
  # GET /people.xml
  def index
    @people = Person.all

    @people = @people.with_status(*params[:status]) if params[:status].present?
    @people = @people.with_roles(*params[:role]) if params[:role].present?

    @people = @people.each { |person|
      person.password = "***************"
    }
    respond_to do |format|
      format.html
      format.json { render json: @people }
      format.xml { render :xml => @people.to_xml }
    end
  end

  # GET /people/1
  # GET /people/1.json
  # GET /people/1.xml
  def show
    @person.password = "***************"
    respond_to do |format|
      format.html
      format.json { render json: @person }
      format.xml { render :xml => @person.to_xml }
    end
  end

  # GET /people/new 
  def new
    @person = Person.new
  end

  # GET /people/1/edit
  def edit
  end

  # POST /people
  # POST /people.json
  def create
    filtered_params = person_params
    filtered_params[:roles] ||= [:leaser]
    filtered_params[:status] ||= [:pending]

    @person = Person.new(filtered_params)

    respond_to do |format|
      if @person.save
        format.html { redirect_to @person, notice: 'Person was successfully created.' }
        format.json { render :show, status: :created, location: @person }
        format.xml { render :show, status: :created, location: @person }
      else
        format.html { render :new }
        format.json { render json: @person.errors, status: :unprocessable_entity }
        format.xml { render xml:  @person.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /people/1
  # PATCH/PUT /people/1.json
  def update
    filtered_params = person_params
    filtered_params[:roles] ||= []
    filtered_params[:status] ||= []

    respond_to do |format|
      if @person.update(filtered_params)
        format.html { redirect_to @person, notice: 'Person was successfully updated.' }
        format.json { render :show, status: :ok, location: @person }
        format.xml { render :show, status: :created, location: @person }
      else
        format.html { render :edit }
        format.json { render json: @person.errors, status: :unprocessable_entity }
        format.xml { render xml:  @person.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /people/1
  # DELETE /people/1.json
  def destroy
    @person.destroy
    respond_to do |format|
      format.html { redirect_to people_url, notice: 'Person was successfully destroyed.' }
      format.json { head :no_content }
      format.xml { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_person
      @person = Person.find(params[:id]) or not_found
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def person_params
      #puts params
      params.require(:person).permit(
        :firstname,
        :middlename,
        :lastname,
        :title,
        :sex,
        :salutation,
        :username,
        :email,
        :password,
        :password_confirmation,
        :roles => [],
        :status => []
      )
      #puts params
      #params
    end
end
