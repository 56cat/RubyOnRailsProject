class Supplier::CsvQueuesController < Supplier::SupplierController
	def index
		@csv_queues = CsvQueue.all
	end

	def export
	  file_name = params[:file_name]
	  file_path = Rails.root.join('public', 'csv_exports', file_name)
	  if File.exist?(file_path)
	    send_file(file_path, filename: "#{file_name}", type: "text/csv", disposition: "attachment")
	  else
	    flash[:alert] = "Không tìm thấy file"
	    redirect_back(fallback_location: supplier_csv_queues_path)
	  end
	end

	def destroy
		csv = CsvQueue.find_by(id: params[:id])
		return redirect_to supplier_csv_queues_path, alert: "Không tìm thấy file" unless csv.present?
		file_path = Rails.root.join('public', 'csv_exports', csv.file_name)
		return redirect_back(fallback_location: root_path), alert: "Không tìm thấy file" unless File.exist?(file_path)
		File.delete(file_path)
		if csv.destroy
			flash[:notice] = 'Xóa thành công'
			redirect_to supplier_csv_queues_path
		else
			flash[:alert] = csv.errors.full_messages.inspect
			redirect_back(fallback_location: supplier_csv_queues_path)
		end
	rescue => e
		flash[:alert] = e.message
		redirect_back(fallback_location: supplier_csv_queues_path)
	end


end
