set(includes
	awaitable_traits.hpp
	is_awaitable.hpp
	async_auto_reset_event.hpp
	async_manual_reset_event.hpp
	async_generator.hpp
	async_mutex.hpp
	async_latch.hpp
	async_scope.hpp
	broken_promise.hpp
	cancellation_registration.hpp
	cancellation_source.hpp
	cancellation_token.hpp
	task.hpp
	sequence_barrier.hpp
	sequence_traits.hpp
	single_producer_sequencer.hpp
	multi_producer_sequencer.hpp
	shared_task.hpp
	shared_task.hpp
	single_consumer_event.hpp
	single_consumer_async_auto_reset_event.hpp
	sync_wait.hpp
	task.hpp
	io_service.hpp
	config.hpp
	on_scope_exit.hpp
	file_share_mode.hpp
	file_open_mode.hpp
	file_buffering_mode.hpp
	file.hpp
	fmap.hpp
	when_all.hpp
	when_all_ready.hpp
	resume_on.hpp
	schedule_on.hpp
	generator.hpp
	readable_file.hpp
	recursive_generator.hpp
	writable_file.hpp
	read_only_file.hpp
	write_only_file.hpp
	read_write_file.hpp
	file_read_operation.hpp
	file_write_operation.hpp
	static_thread_pool.hpp
)

set(netIncludes
	ip_address.hpp
	ip_endpoint.hpp
	ipv4_address.hpp
	ipv4_endpoint.hpp
	ipv6_address.hpp
	ipv6_endpoint.hpp
	socket.hpp
)

set(detailIncludes
	void_value.hpp
	when_all_ready_awaitable.hpp
	when_all_counter.hpp
	when_all_task.hpp
	get_awaiter.hpp
	is_awaiter.hpp
	any.hpp
	sync_wait_task.hpp
	unwrap_reference.hpp
	lightweight_manual_reset_event.hpp
)

set(privateHeaders
	cancellation_state.hpp
	socket_helpers.hpp
	auto_reset_event.hpp
	spin_wait.hpp
	spin_mutex.hpp
)

set(sources
	async_auto_reset_event.cpp
	async_manual_reset_event.cpp
	async_mutex.cpp
	cancellation_state.cpp
	cancellation_token.cpp
	cancellation_source.cpp
	cancellation_registration.cpp
	lightweight_manual_reset_event.cpp
	ip_address.cpp
	ip_endpoint.cpp
	ipv4_address.cpp
	ipv4_endpoint.cpp
	ipv6_address.cpp
	ipv6_endpoint.cpp
	static_thread_pool.cpp
	auto_reset_event.cpp
	spin_wait.cpp
	spin_mutex.cpp
)

if(WIN32)
    list(APPEND detailIncludes
			win32.hpp
			win32_overlapped_operation.hpp)

    list(APPEND netIncludes
			socket.hpp
			socket_accept_operation.hpp
			socket_connect_operation.hpp
			socket_disconnect_operation.hpp
			socket_recv_operation.hpp
			socket_recv_from_operation.hpp
			socket_send_operation.hpp
			socket_send_to_operation.hpp)

    list(APPEND sources
			win32.cpp
			io_service.cpp
			file.cpp
			readable_file.cpp
			writable_file.cpp
			read_only_file.cpp
			write_only_file.cpp
			read_write_file.cpp
			file_read_operation.cpp
			file_write_operation.cpp
			socket_helpers.cpp
			socket.cpp
			socket_accept_operation.cpp
			socket_connect_operation.cpp
			socket_disconnect_operation.cpp
			socket_send_operation.cpp
			socket_send_to_operation.cpp
			socket_recv_operation.cpp
			socket_recv_from_operation.cpp)

		list(APPEND libraries Ws2_32 Mswsock Synchronization)

    list(APPEND libraries Ws2_32 Mswsock Synchronization)
    list(APPEND compile_options /EHsc)

    if("${MSVC_VERSION}" VERSION_GREATER_EQUAL 1900)
      # TODO remove this when experimental/non-experimental include are fixed
      list(APPEND compile_definition _SILENCE_EXPERIMENTAL_FILESYSTEM_DEPRECATION_WARNING=1)
    endif()
else()
	# assuming linux !

	option(CPPCORO_USE_IO_RING "Enable io_ring backend" OFF)

	list(APPEND detailIncludes
		linux.hpp
		linux_io_operation.hpp
		)
	if (CPPCORO_USE_IO_RING)
		find_package(liburing REQUIRED)
		list(APPEND libraries liburing::liburing)

		list(APPEND detailIncludes
			linux_uring_queue.hpp
			)
		list(APPEND compile_definition
			CPPCORO_USE_IO_RING=1
			)
		list(APPEND netIncludes
			socket_accept_operation.hpp
			socket_connect_operation.hpp
			socket_disconnect_operation.hpp
			socket_recv_operation.hpp
			socket_recv_from_operation.hpp
			socket_send_operation.hpp
			socket_send_to_operation.hpp
			)
		list(APPEND sources
			linux_uring_queue.cpp
			io_service.cpp
			file.cpp
			readable_file.cpp
			writable_file.cpp
			read_only_file.cpp
			write_only_file.cpp
			read_write_file.cpp
			file_read_operation.cpp
			file_write_operation.cpp
			socket_helpers.cpp
			socket.cpp
			socket_accept_operation.cpp
			socket_connect_operation.cpp
			socket_disconnect_operation.cpp
			socket_send_operation.cpp
			socket_send_to_operation.cpp
			socket_recv_operation.cpp
			socket_recv_from_operation.cpp
			)
	endif()
	list(APPEND sources
		linux.cpp
		)
endif()

list(TRANSFORM includes PREPEND "${PROJECT_SOURCE_DIR}/include/cppcoro/")
list(TRANSFORM netIncludes PREPEND "${PROJECT_SOURCE_DIR}/include/cppcoro/net/")
list(TRANSFORM detailIncludes PREPEND "${PROJECT_SOURCE_DIR}/include/cppcoro/detail/")

add_library(cppcoro
	${includes}
	${netIncludes}
	${detailIncludes}
	${privateHeaders}
	${sources}
)

target_include_directories(cppcoro PUBLIC
	$<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>
	$<INSTALL_INTERFACE:include>)

target_compile_definitions(cppcoro PUBLIC ${compile_definition})
target_compile_options(cppcoro PUBLIC ${compile_options})

find_package(Coroutines COMPONENTS Experimental Final REQUIRED)
target_link_libraries(cppcoro PUBLIC std::coroutines ${libraries})

install(TARGETS cppcoro EXPORT cppcoroTargets
	LIBRARY DESTINATION lib
	ARCHIVE DESTINATION lib
	RUNTIME DESTINATION bin)
