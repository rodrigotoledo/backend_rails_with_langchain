# frozen_string_literal: true

class Api::V1::ClientsController < ApplicationController
  before_action :set_client, only: [ :show, :update, :destroy, :upload_document ]

  def index
    @clients = Client.includes(:addresses).page(params[:page]).per(params[:limit] || 10)
    clients_data = @clients.map do |client|
      {
        name: client.name,
        nickname: client.nickname,
        email: client.email,
        phone: client.phone,
        documents: {
          cpf: client.cpf,
          rg: client.rg,
          birth_date: client.birth_date
        },
        id: client.id,
        created_at: client.created_at,
        updated_at: client.updated_at,
        addresses: client.addresses,
        similarity_score: 0
      }
    end
    render json: {
      clients: clients_data,
      total: @clients.total_count,
      page: @clients.current_page,
      page_size: @clients.limit_value,
      total_pages: @clients.total_pages,
      has_next: @clients.next_page.present?,
      has_prev: @clients.prev_page.present?
    }
  end

  def show
    client_data = {
      name: @client.name,
      nickname: @client.nickname,
      email: @client.email,
      phone: @client.phone,
      documents: {
        cpf: @client.cpf,
        rg: @client.rg,
        birth_date: @client.birth_date
      },
      id: @client.id,
      created_at: @client.created_at,
      updated_at: @client.updated_at,
      addresses: @client.addresses,
      similarity_score: 0
    }
    render json: client_data
  end

  def create
    client_attributes = params.permit(:name, :nickname, :email, :phone)
    documents = params[:documents]
    if documents
      client_attributes.merge!(documents.permit(:cpf, :rg, :birth_date))
    end
    addresses = params[:addresses]
    if addresses
      client_attributes[:addresses_attributes] = addresses.map do |addr|
        addr.permit(:id, :address_type, :street, :number, :complement, :neighborhood, :city, :state, :zip_code, :_destroy)
      end
    end
    @client = Client.new(client_attributes)
    if @client.save
      render json: @client.as_json(include: :addresses), status: :created
    else
      render json: @client.errors, status: :unprocessable_entity
    end
  end

  def update
    client_attributes = params.permit(:name, :nickname, :email, :phone)
    documents = params[:documents]
    if documents
      client_attributes.merge!(documents.permit(:cpf, :rg, :birth_date))
    end
    addresses = params[:addresses]
    if addresses
      client_attributes[:addresses_attributes] = addresses.map do |addr|
        addr.permit(:id, :address_type, :street, :number, :complement, :neighborhood, :city, :state, :zip_code, :_destroy)
      end
    end
    if @client.update(client_attributes)
      render json: @client.as_json(include: :addresses)
    else
      render json: @client.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @client.destroy
    head :no_content
  end

  def upload_document
    upload = @client.uploads.build(context: params[:context] || 'document')
    upload.file.attach(params[:document])
    if upload.save
      ProcessUploadJob.perform_later(upload.id)
      response = { message: 'Document uploaded successfully', url: url_for(upload.file), upload_id: upload.id }
      render json: response, status: :ok
    else
      render json: { errors: upload.errors }, status: :unprocessable_entity
    end
  end

  private

  def set_client
    @client = Client.includes(:addresses).find(params[:id])
  end
end
