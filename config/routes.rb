ActionController::Routing::Routes.draw do |map|

  map.resources :grading_levels
  map.resources :class_timings
  map.resources :subjects
  map.resources :hostels
  map.resources :attendances
  map.resources :employee_attendances
  map.resources :attendance_reports

  map.report '/per_user_report/:id', :controller => 'exam', :action => 'per_user_report'
#  map.report '/examam/:id', :controller => 'exam', :action => 'examam'
  map.feed 'courses/manage_course', :controller => 'courses' ,:action=>'manage_course'
  map.feed 'courses/manage_batches', :controller => 'courses' ,:action=>'manage_batches'
  map.resources :courses, :has_many => :batches

  map.resources :batches do |batch|
    batch.resources :exam_groups
    batch.resources :additional_exam_groups
    batch.resources :elective_groups, :as => :electives
  end

  map.resources :exam_groups do |exam_group|
    exam_group.resources :exams, :member => { :save_scores => :post }
  end

 map.resources :additional_exam_groups do |additional_exam_group|
    additional_exam_group.resources :additional_exams , :member => { :save_additional_scores => :post }
  end

  map.root :controller => 'user', :action => 'login'

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id/:id2'
  map.connect ':controller/:action/:id.:format'
  
  #Report Cards
 map.connect 'report_card/student/:id', :controller => 'exam', :action => 'generate_report_card4'
 
 #Performance Analysis
 map.connect 'performance/index', :controller => 'exam', :action => 'performance_index'
 
 map.connect 'exam/class/top_ten', :controller => 'exam', :action => 'class_top'
 

 
 map.connect 'exam/class/top_form', :controller => 'exam', :action => 'form_top'
 

 
 map.connect 'exam/best_class_form', :controller => 'exam', :action => 'best_class_form'
 

 
 #Course, Section and Batch Management
  map.connect 'course/:name/sections', :controller => 'courses', :action => 'section_index' 
  
  
  
 #Hostel
  map.connect 'add/hostel/:id', :controller => 'students', :action => 'add_hostel'
  
  map.connect 'add/hostels', :controller => 'students', :action => 'update_hostel'  
 end
