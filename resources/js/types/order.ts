export interface OrderStatus {
    value: string
    label: string
}

export interface OrderFilters {
    search: string
    status: string
    date_from: string
    date_to: string
}

export interface Order {
    id: number
    order_number: string
    customer_name: string
    customer_email: string
    customer_phone: string
    customer_organization?: string | null
    delivery_method: string
    delivery_method_label: string
    delivery_address?: string | null
    comment?: string | null
    total_amount: string
    status: string
    status_label: string
    status_color: string
    created_at: string
    items_count?: number
    last_status_change?: string
}
