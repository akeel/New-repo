class PerUserReport < Prawn::Document
  def age dob
    now = Time.now.utc.to_date
    now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
  end

  def to_pdf id
    @batch = Batch.find id	
    @exam_groups = ExamGroup.find_all_by_batch_id(@batch.id)
    @mean_mark_class = @batch.class_mean_marks*100
    @students = @batch.students

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

      course = @batch.course
      @form_mean_marks = course[student]
      @form_mean_marks = 0.0 if @form_mean_marks.nil?
      @grade_form = !@form_mean_marks.nil? ?  GradingLevel.percentage_to_grade(@form_mean_marks,nil) : GradingLevel.percentage_to_grade(0.0,nil)
      
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
        student_image = "#{student.photo.path(:thumb)}" if !student.photo_file_name.nil?
        bounding_box [30, 720], :width => 420, :height => 130 do
          text_box 'MANG\'U HIGH SCHOOL', :size => 22, :width => 350, :at => [95, cursor], :style => :bold
          move_down 25
          text_box 'P.O BOX 314- 01000, THIKA ', :size => 12, :at => [95, cursor]
          move_down 16
          text_box 'TEL:067-24146,24267', :size => 12, :at => [95, cursor]
          move_down 16
          text_box '<i>Email:info@manguhigh.com</i>', :size => 12, :at => [95, cursor],:inline_format => true
          move_down 16
          text_box '<i>Website:www.manguhigh.com</i>', :size => 12, :at => [95, cursor],:inline_format => true
          move_down 22
          text_box 'PROGRESS REPORT FORM', :size => 20, :width => 350, :at => [90, cursor]
        end


        image student_image,:at=>[400,715] if !student_image.nil?

    ### watermark
        text_box "<color rgb='FF00FF'>#{student.serial_number}</color>", :size => 28,:at=>[200,300],:rotate=>45,:inline_format => true

    ###
     move_down 5        
     table([["Name: #{student.first_name.to_s.upcase} #{student.middle_name.to_s.upcase} #{student.last_name.to_s.upcase}", "Admission No.: #{student.admission_no}", "KCPE MARKS:#{student.previous_month_marks}"],
                 ["#{@batch.course.full_name}   Term: #{@batch.name}", "Year: #{@batch.start_date.year.to_s}", "House: #{student.hostel.house.upcase if !student.hostel.nil?}"],
                 ["Class Mean Marks: #{"%.2f" %@class_percentage}", "Student Mean Marks: #{"%.2f" %@percentage}", "Form Mean Marks: #{"%.2f" %@form_mean_marks}"], 
                 ["Class Mean Grade: #{@grade_class.name}", "Student Mean Grade: #{@grade_student.name}", "Form Mean Grade: #{@grade_form.name}"]], :cell_style => {:border_width => 0,:size =>10 ,:width => 180}) 

 
        # table
        move_down 10
        header_table = [['<b>SUBJECT   </b>', "<b>AVERAGE CAT\n MARKS( out of 40)</b>", "<b>END TERM\n MARKS (out of 60)</b>", "<b>TOTAL SCORE\n(out of 100)</b>", "<b>EXAM\nGRADE</b>","<b>SUBJECT POSITION</b>", "<b>TEACHER'S REMARK</b>", "<b>TEACHER'S\nINITIAL</b>"]]

        @final_exam_score = 0.0
        @final_exam_score_total = 0.0 
        @final_mean_grade = "-"
        @cat_score_final = 0
	@end_score_final = 0	
        @subjects.each do |s|
    		@mmg = 1
    		@g = 1
       		student_calculated_total_weightage = []
                cat_marks = 0.0
                cat_total = 0.0
                end_marks = 0.0
                end_totals = 0.0
		cat_score = 0
		cat_weight = ""
		end_score = 0
		end_weight = ""
		total_cat_score = 0
                cal_twenty_percent = 0.0 
                end_sixty_percent = 0.0
		  @exam_groups.each do |exam_group|						
		   @exam =Exam.find_by_subject_id_and_exam_group_id(s.id,exam_group.id)
		   exam_score = ExamScore.find_by_student_id(student.id, :conditions=>{:exam_id=>@exam.id}) unless @exam.nil?
		         unless @exam.nil?
		            unless exam_score.nil?
    		               if exam_group.is_term?
                                 # 60% of the term 
                                  end_marks = exam_score.marks
                                  end_marks_totals = exam_score.exam.maximum_marks
                                  if !end_marks.nil? &&  end_marks_totals > 0.0 
                                    end_sixty_percent += (((end_marks/end_marks_totals)*300)/5)
                                  else
                                    end_sixty_percent += 0.0
                                  end
                                  #end 
			          end_score = exam_score.calculated_weightage
			          end_weight += exam_score.grading_level.to_s
			       else 

                                 # According to 20 % of each term 
                                  cat_marks = exam_score.marks
                                  cat_max_mark = exam_score.exam.maximum_marks
                                  if !cat_marks.nil? &&  cat_marks > 0.0 
                                    cal_twenty_percent += (((cat_marks/cat_max_mark)*100)/5)
                                  else
                                    cal_twenty_percent += 0.0
                                  end
                                #end  

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

        # exam total score & grade
        total_exam_score = end_sixty_percent + cal_twenty_percent
        @final_exam_score += total_exam_score
        @final_exam_score_total  += 100
        unless total_exam_score == 0
           @total_grade = GradingLevel.percentage_to_grade(total_exam_score*100/100,nil).name
           else
           @total_grade = "-"
	end
         
        #end
        @sub_pos,@sub_total = student.current_subject_position(s.id)
        header_table += [["<b>#{s.name}</b>" ,"#{cal_twenty_percent.ceil}", "#{end_sixty_percent.ceil}", "#{total_exam_score.ceil}", "#{@total_grade}","#{@sub_pos}/#{@sub_total}" ,"#{teacher_remark(@total_grade,s)}", "<b>#{s.teacher_initial_name}</b>"]]
        @cat_score_final += cat_score
        @end_score_final += end_score 
        end

        #end final means grade
           unless @final_exam_score == 0
           @final_mean_grade = GradingLevel.percentage_to_grade(@final_exam_score*100/@final_exam_score_total,nil).name
           else
           @final_mean_grade = "-"
	end
        #end
 

        
        header_table += [["<b>TOTALS</b>","","","<b>#{@final_exam_score.ceil}</b> out\nof <b>#{@final_exam_score_total}<b>", "<b>#{@final_mean_grade}</b>","", "", ""]]
        table header_table, :width => self.bounds.width, :cell_style => {:size => 6,:inline_format => true } do
             columns(0).width = 70
        end

       move_down 2
       table([["Class position: <b>#{@pos}</b> out of <b>#{@pos_of}</b>","Form position: <b>#{@pos2}</b> out of <b>#{@pos_of2}</b>"]], :cell_style => {:border_width => 0,:size =>10,:inline_format => true}) 

    
  

        line [50, 180],[50,280]
        stroke
        line [50, 180],[290,180]
        stroke


        text_box "0" ,:at=>[30,180], :size => 6
        text_box "E" ,:at=>[30,200], :size => 6
        text_box "D" ,:at=>[30,220], :size => 6
        text_box "------------------------------------------------------------" ,:at=>[50,235]
        text_box "C" ,:at=>[30,240], :size => 6
        text_box "B" ,:at=>[30,260], :size => 6
        text_box "A" ,:at=>[30,280], :size => 6


        text_box "F1-1" ,:at=>[65,175], :size => 5
        text_box "F1-2" ,:at=>[85,175], :size => 5
        text_box "F1-3" ,:at=>[105,175], :size => 5
        text_box "F2-1" ,:at=>[125,175], :size => 5
        text_box "F2-2" ,:at=>[145,175], :size => 5
        text_box "F2-3" ,:at=>[165,175], :size => 5
        text_box "F3-1" ,:at=>[185,175], :size => 5
        text_box "F3-2" ,:at=>[205,175], :size => 5
        text_box "F3-3" ,:at=>[225,175], :size => 5
        text_box "F4-1" ,:at=>[245,175], :size => 5
        text_box "F4-2" ,:at=>[265,175], :size => 5
        text_box "F4-3" ,:at=>[285,175], :size => 5


         line [70, 240],[90,220]
         stroke

         line [90, 220],[110,280]
         stroke


        move_down 135
        group do
          bounding_box [0, cursor], :width => self.bounds.width, :height => 32 do
            stroke_bounds
            move_down 7
            text_box "Class Teacher's Remarks:", :size => 10, :width => 140, :at => [5, cursor], :style => :bold
          end
          bounding_box [0, cursor], :width => self.bounds.width, :height => 32 do
            stroke_bounds
            move_down 6
            text_box "Class Teacher's signature:", :size => 10, :width => 140, :at => [5, cursor], :style => :bold
          end
          bounding_box [0, cursor], :width => self.bounds.width, :height => 32 do
            stroke_bounds
            move_down 6
            text_box "Principal's Remarks", :size => 10, :width => 140, :at => [5, cursor], :style => :bold
          end
          bounding_box [0, cursor], :width => self.bounds.width, :height => 32 do
            stroke_bounds
            move_down 6
            text_box "Principal's signature", :size => 10, :width => 140, :at => [5, cursor], :style => :bold
          end
        end

        move_down 6
        group do
          text_box 'Next Term Begins on: ', :size => 10, :width => 240, :at => [0, cursor], :style => :bold
          text_box 'Ends on: ', :size => 10, :width => 240, :at => [250, cursor], :style => :bold
        end
        
        move_down 12
        group do
          text_box "#{student.serial_number}", :size => 10, :at => [275, cursor], :style => :bold
        end



        



        start_new_page

 
      end
      # render the document
      render
    end
  end
   
  def teacher_remark(grade,subject)
      if !grade.blank?
          case grade
	  when "A"
	     grades =  subject.name.to_s == "KISWAHILI" ?  'Hongera' : "Excellent"
          when "A-"
	     grades =  subject.name.to_s == "KISWAHILI" ?  'Vizuri sana' : "Very good"
          when "B+"
	     grades =  subject.name.to_s == "KISWAHILI" ?  'Kazi Nzuri' : "Good Work"
	  when "B"
             grades =  subject.name.to_s == "KISWAHILI" ?  'Vizuri. Jitahidi.' : "Good. Aim Higher."
          when "B-"
	     grades =  subject.name.to_s == "KISWAHILI" ?  'Vizuri. Jitahidi.' : "Good. Aim Higher." 
	  when "C+"
	     grades = subject.name.to_s == "KISWAHILI" ?  'Jitahidi Zaidi' : "Fair. Aim Higher."
          when "C"
	     grades = subject.name.to_s == "KISWAHILI" ?  'Wastani. Jitahidi.' : "Fair. Work Harder."
          when "C-"
	     grades = subject.name.to_s == "KISWAHILI" ?  'Wastani. Jitahidi.' : "Fair. Work Harder."
          when "D+"
	     grades = subject.name.to_s == "KISWAHILI" ?  'Jitahidi' : "Work Harder"
          when "D"
	     grades = subject.name.to_s == "KISWAHILI" ?  'Jitahidi' : "Work Harder"
          when "D-"
	     grades = subject.name.to_s == "KISWAHILI" ?  'Jitahidi' : "Work Harder"
          when "E"
	     grades = subject.name.to_s == "KISWAHILI" ?  'Lazima Utie Bidii' : "Poor. Must Work!"
	  end
      else
         grades = ''
      end
      return grades 
  end

end
