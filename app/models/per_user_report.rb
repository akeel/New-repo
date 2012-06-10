class PerUserReport < Prawn::Document
  def age dob
    now = Time.now.utc.to_date
    now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
  end

  def to_pdf id
    @batch = Batch.find id	
    @exam_groups = ExamGroup.find_all_by_batch_id(@batch.id)
    @mean_mark_class = @batch.class_mean_marks*100
    @students = [@batch.students.first]
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
        student_image = "#{student.photo.path(:thumb)}" if !student.photo_file_name.nil?
        bounding_box [30, 720], :width => 420, :height => 130 do
          text_box 'MANG\'U HIGH SCHOOL', :size => 22, :width => 350, :at => [95, cursor], :style => :bold
          move_down 25
          text_box 'P.O BOX 314- 01000, THIKA ', :size => 18, :at => [95, cursor], :style => :bold
          move_down 20
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
                 ["Class Mean Marks: #{"%.2f" %@class_percentage}", "Student Mean Marks: #{"%.2f" %@percentage}", ""], 
                 ["Class Mean Grade: #{@grade_class.name}", "Student Mean Grade: #{@grade_student.name}", ""]], :cell_style => {:border_width => 0,:size =>10 ,:width => 180}) 
               

        # table
        move_down 10
        header_table = [['<b>SUBJECT   </b>', "<b>AVERAGE CAT\n MARKS</b>( out of 40)", "<b>END TERM\n MARKS (out of 60)</b>", "<b>TOTAL SCORE\n(out of 100)</b>", "<b>EXAM\nGRADE</b>","<b>SUBJECT POSITION</b>", "<b>TEACHER'S REMARK</b>", "<b>TEACHER'S\nINITIAL</b>"]]

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
        header_table += [["<b>#{s.name}</b>" ,"#{cal_twenty_percent.round(0)}", "#{end_sixty_percent.round(0)}", "#{total_exam_score.round(0)}", "#{@total_grade}","#{@sub_pos}/#{@sub_total}" ,"#{teacher_remark(@total_grade)}", "<b>#{s.teacher_initial_name}</b>"]]
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
 

        
        header_table += [["<b>TOTALS</b>","","","<b>#{@final_exam_score.round(0)}</b> out\nof <b>#{@final_exam_score_total}<b>", "<b>#{@final_mean_grade}</b>","", "", ""]]
        table header_table, :width => self.bounds.width, :cell_style => { :size => 5,:inline_format => true }

       move_down 2
       table([["Class position: <b>#{@pos}</b> out of <b>#{@pos_of}</b>","Form position: <b>#{@pos2}</b> out of <b>#{@pos_of2}</b>"]], :cell_style => {:border_width => 0,:size =>10,:inline_format => true}) 

   
       move_down 8
        group do
          bounding_box [0, cursor], :width => self.bounds.width, :height => 64 do
            stroke_bounds
            move_down 7
            text_box "Class Teacher's Remarks:", :size => 10, :width => 140, :at => [5, cursor], :style => :bold
          end
          bounding_box [0, cursor], :width => self.bounds.width, :height => 64 do
            stroke_bounds
            move_down 6
            text_box "Principal's Remarks", :size => 10, :width => 140, :at => [5, cursor], :style => :bold
          end
        end

        move_down 8
        group do
          text_box 'Next Term Begins on: ', :size => 10, :width => 240, :at => [0, cursor], :style => :bold
          text_box 'Ends on: ', :size => 10, :width => 240, :at => [250, cursor], :style => :bold
          move_down 15
          text_box 'All students report by 5.30 p.m. on the day before the term begins in full scholl uniform.', :size => 10, :width => 500, :at => [0, cursor], :style => :bold
        end
  

        line [50, 20],[50,120]
        stroke
        line [50, 20],[290,20]
        stroke
        
        text_box "0" ,:at=>[30,25]
        text_box "20" ,:at=>[30,45]
        text_box "40" ,:at=>[30,65]
        text_box "60" ,:at=>[30,85]
        text_box "80" ,:at=>[30,105]
        text_box "100" ,:at=>[30,125]
     

        text_box "F1-1" ,:at=>[65,15], :size => 6
        text_box "F1-2" ,:at=>[85,15], :size => 6
        text_box "F1-3" ,:at=>[105,15], :size => 6
        text_box "F2-1" ,:at=>[125,15], :size => 6
        text_box "F2-2" ,:at=>[145,15], :size => 6
        text_box "F2-3" ,:at=>[165,15], :size => 6
        text_box "F3-1" ,:at=>[185,15], :size => 6
        text_box "F3-2" ,:at=>[205,15], :size => 6
        text_box "F3-3" ,:at=>[225,15], :size => 6
        text_box "F4-1" ,:at=>[245,15], :size => 6
        text_box "F4-2" ,:at=>[265,15], :size => 6
        text_box "F4-3" ,:at=>[285,15], :size => 6


  
#        Term1    
         line [70, 60],[90,60]
         stroke
 
         line [90, 100],[110,60]
         stroke



        


# #       Term1    
#         line [130, 140],[230,180]
#         stroke
#         line [230, 180],[330,90]
#         stroke
#         line [330,90],[430,180]
#         stroke
#         line [430,180],[530,150]
#         stroke
# 
# #       Term2    
#         line [130, 180],[230,160]
#         stroke
#         line [230, 160],[330,64]
#         stroke
#         line [330,64],[430,77]
#         stroke
#         line [430,77],[530,88]
#         stroke

        start_new_page

 
      end
      # render the document
      render
    end
  end
   
  def teacher_remark(grade)
      if !grade.blank?
          case grade.at(0)
	  when "A"
	     grades =  'Vizuri'
	  when "B"
	     grades = 'Bora'
	  when "C"
	     grades = 'Wastani'
          when "D"
	     grades = 'Duni'
	  end
      else
         grades = ''
      end
      return grades 
  end

end
