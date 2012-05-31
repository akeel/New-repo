class PerUserReport < Prawn::Document
  def age dob
    now = Time.now.utc.to_date
    now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
  end

  def to_pdf id

    @batch = Batch.find 2
    @exam_groups = ExamGroup.find_all_by_batch_id(@batch.id)
    @mean_mark_class = @batch.class_mean_marks*100
    @students = @batch.students.find(:all,:conditions=>{:id => 407})
	
    if @batch
      @students.each do |student|
      @subjects = student.subjects         
      @max_total = 0
      @marks_total= 0
      @total_wt = 0
      @exam_groups.each do |exam_group|
				unless exam_group.exam_type == "Grades"
				@exam = Exam.find_by_exam_group_id(exam_group.id)
				@total_wt += @exam.weightage if !@exam.nil?
      	@max_total +=  exam_group.total_marks(student)[1]
        @marks_total += exam_group.total_marks(student)[0]
    		end
    	end
   	@tot_weight = @total_wt * @subjects.size
    	@class_percentage = @tot_weight > 0  ?  @mean_mark_class/@tot_weight : 0 
    	@percentage = (@marks_total*100/@max_total.to_f)  unless @max_total==0
      @percentage = 0 if @percentage.nil?
      @grade_class = GradingLevel.percentage_to_grade(@class_percentage,nil)
      @grade_student = GradingLevel.percentage_to_grade(@percentage,nil)
      @pos,@pos_of = student.current_class_position
      @pos2,@pos_of2 = student.current_course_position
          
        #report header
        image "#{RAILS_ROOT}/public/images/report_logo.jpg", :scale => 0.4

        bounding_box [100, 705], :width => 420, :height => 110 do
          text_box 'MANGU HIGH SCHOOL', :size => 22, :width => 350, :at => [105, cursor], :style => :bold
          move_down 35
          text_box 'P.O BOX 314- 01000 THIKA TEL 25420 2319804', :size => 13, :width => 420, :at => [80, cursor]
          move_down 35
          text_box 'PROGRESS REPORT FORM', :size => 20, :width => 350, :at => [90, cursor]
        end
###
      move_down 15
         table([ ["Name: #{student.first_name} #{student.middle_name} #{student.last_name}", "Admission No.: #{student.admission_no}", "Age: #{age(student.date_of_birth).to_s}"],
                 ["#{@batch.course.full_name}   Term: #{@batch.name}", "Year: #{@batch.start_date.year.to_s}", "House: #{}"],
                 ["Class Mean Marks: #{"%.2f" %@class_percentage}", "Student Mean Marks: #{"%.2f" %@percentage}", "Class position: #{@pos} out of #{@pos_of}"], 
                  ["Class Mean Grade: #{@grade_class.name}", "Student Mean Grade: #{@grade_student.name}", "Form position: #{@pos2} out of #{@pos_of2}"]], :cell_style => {:size =>10 ,:width => 180,:border_width => 0}) 
               



         




###
        # student data line 1
        move_down 40
        text_box 'Name:', :size => 10, :width => 35, :at => [0, cursor]
        text_box "#{student.first_name} #{student.middle_name} #{student.last_name}", :size => 8, :width => 230, :at => [35, cursor]
        text_box 'Admission No.:', :size => 10, :width => 75, :at => [270, cursor]
        text_box student.admission_no, :size => 10, :width => 100, :at => [350, cursor]
        text_box 'Age:', :size => 10, :width => 35, :at => [470, cursor]
        text_box age(student.date_of_birth).to_s, :size => 10, :width => 35, :at => [510, cursor]

        # student data line 2
        move_down 15
        text_box @batch.course.full_name, :size => 10, :width => 105, :at => [0, cursor], :style => :bold
        text_box 'Term:', :size => 10, :width => 95, :at => [100, cursor]
        text_box @batch.name, :size => 10, :width => 110, :at => [130, cursor]
        text_box 'Year:', :size => 10, :width => 55, :at => [270, cursor]
        text_box @batch.start_date.year.to_s, :size => 10, :width => 55, :at => [300, cursor]
        text_box 'House:', :size => 10, :width => 55, :at => [430, cursor]
        text_box '', :size => 10, :width => 100, :at => [465, cursor]

        # student data line 3
        move_down 15             
              
        text_box 'Class Mean Marks:', :size => 10, :width => 125, :at => [0, cursor]                      
        text_box "#{"%.2f" %@class_percentage}", :size => 10, :width => 40, :at => [90, cursor]
        text_box 'Student Mean Marks:', :size => 10, :width => 125, :at => [180, cursor]
        text_box "#{"%.2f" %@percentage}", :size => 10, :width => 40, :at => [280, cursor]
        text_box 'Class position:', :size => 10, :width => 125, :at => [400, cursor]
        text_box "#{@pos} out of #{@pos_of}", :size => 10, :width => 80, :at => [470, cursor]

        # student data line 4
        move_down 15
        text_box 'Class Mean Grade:', :size => 10, :width => 125, :at => [0, cursor]
        text_box "#{@grade_class.name}", :size => 10, :width => 40, :at => [90, cursor]
        text_box 'Student Mean Grade:', :size => 10, :width => 125, :at => [180, cursor]
        text_box "#{@grade_student.name}", :size => 10, :width => 40, :at => [280, cursor]
        text_box 'Form position:', :size => 10, :width => 125, :at => [400, cursor]
        text_box "#{@pos2} out of #{@pos_of2}", :size => 10, :width => 80, :at => [470, cursor]

        # table
        move_down 25
        header_table = [['Subject', "TERM\nMARK", "TERM\nGRADE", "EXAM\nMARK", "EXAM\nGRADE", "TEACHER'S REMARK", "TEACHER'S\nSIGN"]]
        @cat_score_final = 0
			 	@end_score_final = 0	
        @subjects.each do |s|
    			@mmg = 1
    			@g = 1
       		student_calculated_total_weightage = []
				  cat_score = 0
				  cat_weight = ""
				  end_score = 0
				  end_weight = ""
				  total_cat_score = 0
				  @exam_groups.each do |exam_group|						
						@exam = Exam.find_by_subject_id_and_exam_group_id(s.id,exam_group.id)
				        exam_score = ExamScore.find_by_student_id(student.id, :conditions=>{:exam_id=>@exam.id})unless @exam.nil?
				         unless @exam.nil?
				           unless exam_score.nil?
										if exam_group.is_term?
				             end_score = exam_score.calculated_weightage
				             end_weight += exam_score.grading_level.to_s
				            else 
											cat_score += exam_score.calculated_weightage
				              cat_weight += exam_score.grading_level.to_s
				              total_cat_score += cat_score
				            end
				            student_calculated_total_weightage << exam_score.calculated_weightage
				           end
				         end
								end
											        
						unless total_cat_score == 0
            @grade = GradingLevel.percentage_to_grade(cat_score*100/total_cat_score,nil).name
            else
            @grade = "-"
						end
												
				                                  
          header_table += [[s.name, "#{cat_score}", "#{@grade}", "#{end_score}", "#{end_weight.blank? ? "-" : end_weight}", "", ""]]
          @cat_score_final += cat_score
			 		@end_score_final += end_score	
       
        end
        
        header_table += [["TOTAL MARKS", @cat_score_final, "",@end_score_final, "", "#{@cat_score_final + @end_score_final} out of #{@tot_weight}", ""]]
        table header_table, :width => self.bounds.width, :cell_style => { :size => 6 }

        # after table comments
        move_down 15
        
        text_box 'Mean marks:', :size => 10, :width => 125, :at => [200, cursor]
        text_box "#{"%.2f" %@percentage}", :size => 10, :width => 40, :at => [270, cursor]
        text_box 'Mean Grade:', :size => 10, :width => 125, :at => [400, cursor]
        text_box "#{@grade_student.name}", :size => 10, :width => 80, :at => [460, cursor]
        
        move_down 15
        group do
          bounding_box [0, cursor], :width => self.bounds.width, :height => 70 do
            stroke_bounds
            move_down 7
            text_box 'REMARKS:', :size => 10, :width => 125, :at => [20, cursor], :style => :bold
            move_down 15
            text_box '1.', :size => 10, :width => 10, :at => [10, cursor], :style => :bold
            text_box 'Excellent Performance', :size => 10, :width => 150, :at => [20, cursor]
            text_box '4.', :size => 10, :width => 10, :at => [170, cursor], :style => :bold
            text_box 'Has Improved', :size => 10, :width => 100, :at => [180, cursor]
            text_box '7.', :size => 10, :width => 10, :at => [290, cursor], :style => :bold
            text_box 'Lacks Concentration', :size => 10, :width => 100, :at => [300, cursor]
            text_box '10.', :size => 10, :width => 20, :at => [470, cursor], :style => :bold
            text_box 'Absent', :size => 10, :width => 100, :at => [490, cursor]
            move_down 15
            text_box '2.', :size => 10, :width => 10, :at => [10, cursor], :style => :bold
            text_box 'Hard Working', :size => 10, :width => 150, :at => [20, cursor]
            text_box '5.', :size => 10, :width => 10, :at => [170, cursor], :style => :bold
            text_box 'Can do better', :size => 10, :width => 100, :at => [180, cursor]
            text_box '8.', :size => 10, :width => 10, :at => [290, cursor], :style => :bold
            text_box 'Does not take corrections seriously', :size => 10, :width => 200, :at => [300, cursor]
            move_down 15
            text_box '3.', :size => 10, :width => 10, :at => [10, cursor], :style => :bold
            text_box 'Takes Keen Interest', :size => 10, :width => 150, :at => [20, cursor]
            text_box '6.', :size => 10, :width => 10, :at => [170, cursor], :style => :bold
            text_box 'Has dropped', :size => 10, :width => 100, :at => [180, cursor]
            text_box '9.', :size => 10, :width => 10, :at => [290, cursor], :style => :bold
            text_box 'Not serious in assignments', :size => 10, :width => 200, :at => [300, cursor]
          end
        end

        move_down 15
        group do
          bounding_box [0, cursor], :width => self.bounds.width, :height => 20 do
            stroke_bounds
            move_down 7
            text_box 'Clubs and Games:', :size => 10, :width => 125, :at => [4, cursor], :style => :bold
          end
          bounding_box [0, cursor], :width => self.bounds.width, :height => 20 do
            stroke_bounds
            move_down 7
            text_box 'Responsibilities:', :size => 10, :width => 125, :at => [12, cursor], :style => :bold
          end
        end
        
				move_down 15
        group do
          bounding_box [0, cursor], :width => self.bounds.width, :height => 40 do
            stroke_bounds
            move_down 7
            text_box "Class Teacher's Remarks:", :size => 10, :width => 125, :at => [5, cursor], :style => :bold
          end
          bounding_box [0, cursor], :width => self.bounds.width, :height => 40 do
            stroke_bounds
            move_down 7
            text_box "House Matron's Remarks:", :size => 10, :width => 125, :at => [5, cursor], :style => :bold
          end
          bounding_box [0, cursor], :width => self.bounds.width, :height => 40 do
            stroke_bounds
            move_down 7
            text_box "Principal's Remarks", :size => 10, :width => 125, :at => [5, cursor], :style => :bold
          end
        end

        move_down 15
        group do
          text_box 'Next Term Begins on: ', :size => 10, :width => 240, :at => [0, cursor], :style => :bold
          text_box 'Ends on: ', :size => 10, :width => 240, :at => [250, cursor], :style => :bold
          move_down 15
          text_box 'All students report by 5.30 p.m. on the day before the term begins in full scholl uniform.', :size => 10, :width => 500, :at => [0, cursor], :style => :bold
        end

        start_new_page
      end
      # render the document
      render
    end
  end
end
