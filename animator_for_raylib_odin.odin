package animator_for_raylib_odin

import rl "vendor:raylib"
import "core:fmt"

Animator :: struct {
	/// sprite width / Total columns per row
	frame_width: f32,

	/// sprite height / Total rows
	frame_height: f32,

	/// Used for timing.
	time_remaining_frames_counter: f32,

	/// Used for querying how many frames have passed.
	playback_position: uint,

	/// Used for changing sprite if the delay parameter is used in Changesprite() function.
	delay_frames_counter: uint,

	/// Total amount of rows.
	rows: uint,

	/// Total amount of columns.
	columns: uint,

	/// speed of animation.
 	framerate: uint,

 	/// The current row the animator is on. (Zero based)
 	current_row: uint,

 	/// The current column the animator is on. (Zero based)
 	current_column: uint,

 	/// The current frame the animator is on. (Zero based)
 	current_frame: uint,

 	/// Should flip the sprite horizontally?
 	flip_h: bool,

 	/// Should flip the sprite vertically?
 	flip_v: bool,

 	/// Used to query whether the animator is looping or not.
 	can_loop: bool,

 	/// Used to query whether the animator is in reverse mode or not.
 	reverse: bool,

 	/// Used to query whether the animator should go to the next row in the sprite-sheet.
 	continuous: bool,

 	/// Used to query whether the animator is paused or not.
 	paused: bool,

 	/// Used to query whether the animator is finished playing or not.
 	is_animation_finished: bool,

 	/// Used to query whether the animator has started playing or not.
 	has_started_playing: bool,

 	/// The frame rectangle is used to draw only a part of the whole sprite-sheet
 	frame_rec: rl.Rectangle,

 	/// The sprite the animator is using
 	sprite: rl.Texture2D,

 	/// The name of this animator
 	name: string,
}

/// <summary>Initializes an animator instance.</summary>
/// <param name="animator_name">A name the animator will be identified by.</param>
/// <param name="num_of_frames_per_row">The amount of frames/columns in a row.</param>
/// <param name="num_of_rows">The amount of rows in the sprite sheet.</param>
/// <param name="speed">The animation speed in frames per second.</param>
/// <param name="play_in_reverse">Should the animator play the sprite in reverse play mode?</param>
/// <param name="continuous">Should the animator automatically go to the next row in the sprite sheet?</param>
/// <param name="looping">Should the animator loop indefinitely?</param>
init :: proc(a: ^Animator, animator_name: string, num_of_frames_per_row: uint, num_of_rows: uint, speed: uint, play_in_reverse: bool = false, continuous: bool = true, looping: bool = true) {
	a.name = animator_name
	a.framerate = speed == 0 ? 1 : speed
	a.columns = num_of_frames_per_row
	a.rows = num_of_rows == 0 ? 1 : num_of_rows
	a.reverse = play_in_reverse
	a.can_loop = looping
	a.continuous = continuous
}

/// <summary>Assigns a sprite for the animator to use. (This should be called once)</summary>
/// <param name="sprite">The sprite the animator will use.</param>
assign_sprite :: proc(a: ^Animator, sprite: ^rl.Texture2D) {
	a.sprite = sprite^
	restart(a)
}

/// <summary>Changes the sprite the animator is using.</summary>
/// <param name="new_sprite">The new sprite the animator will change to. Will reset to beginning frame.</param>
/// <param name="num_of_frames_per_row">The amount of frames/columns in a row.</param>
/// <param name="num_of_rows">The amount of rows in the sprite sheet.</param>
/// <param name="speed">The animation speed in frames per second.</param>
/// <param name="delay_in_seconds">The amount of time (in seconds) to change to the new sprite. A value of 0.0 is instant/no delay.</param>
/// <param name="play_in_reverse">Should the animator play the new sprite in reverse play mode?</param>
/// <param name="continuous">Should the animator automatically go to the next row in the sprite sheet?</param>
/// <param name="looping">Should the animator loop indefinitely?</param>
change_sprite :: proc(a: ^Animator, new_sprite: ^rl.Texture2D, num_of_frames_per_row: uint, num_of_rows: uint, speed: uint, delay_in_seconds: f32 = 0.0, play_in_reverse: bool = false, continuous: bool = false, looping: bool = true) {
	a.delay_frames_counter += 1

	if rl.GetFPS() >= 0
	{
		if f32(a.delay_frames_counter) > delay_in_seconds * f32(rl.GetFPS())
		{
			a.rows = num_of_rows == 0 ? 1 : num_of_rows
			a.columns = num_of_frames_per_row
			a.framerate = speed
			a.can_loop = looping
			a.continuous = continuous
			a.reverse = play_in_reverse
			a.playback_position = 0
			a.delay_frames_counter = 0
			a.is_animation_finished = false
			a.has_started_playing = !a.paused

			assign_sprite(a, new_sprite)
		}
	}
}

/// <summary>Flips the sprite-sheet horizontally or vertically, or both.</summary>
/// <param name="horizontal_flip">Flips the sprite sheet horizontally. DOES NOT WORK, set this to false.</param>
/// <param name="vertical_flip">Flips the sprite sheet vertically.</param>
flip_sprite :: proc(a: ^Animator, horizontal_flip: bool, vertical_flip: bool = true) {
	//frame_rec.width = fabsf(frame_rec.width) * (horizontal_flip ? -1 : 1)
	//frame_rec.height = fabsf(frame_rec.height) * (vertical_flip ? -1 : 1)

	a.flip_h = horizontal_flip
	a.flip_v = !a.flip_v

	if horizontal_flip && vertical_flip
	{
		a.frame_rec.width *= -1
		a.frame_rec.height *= -1
	}
	else if horizontal_flip
	{
		a.frame_rec.width *= -1
	}
	else if vertical_flip
	{	
		a.frame_rec.height *= -1
	}

	fmt.printf("Width: %v, Height: %v\n", a.frame_rec.width, a.frame_rec.height)
}

/// <summary>Set whether the animator should loop or not.</summary>
/// <param name="looping">Should the animator loop?</param>
set_looping :: proc(a: ^Animator, looping: bool) {
	a.can_loop = looping
}

/// <summary>Set whether the animator should go to the next row in the sprite sheet or not.</summary>
/// <param name="is_continuous">Should the animator continue to the next row?</param>
set_continuous :: proc(a: ^Animator, is_continuous: bool) {
	a.continuous = is_continuous
}

/// <summary>Set a new framerate the animator will use.</summary>
/// <param name="new_framerate">The new speed of animation.</param>
set_framerate :: proc(a: ^Animator, new_framerate: uint) {
	a.framerate = new_framerate
}

/// <summary>Jump to a frame in the sprite-sheet.</summary>
/// <param name="frame_number">The frame number in the sprite sheet. (Zero-based)</param>
go_to_frame :: proc(a: ^Animator, frame_number: uint) {
	// Does frame exist in sprite-sheet
	if frame_number < a.columns * a.rows
	{
		go_to_row(a, frame_number / a.columns)
		go_to_column(a, frame_number % a.columns)
	}
	else {
		fmt.printf("ERROR from GoToFrame(): Frame %v does not exist! %v sprite has frames from %v to %v.\n", frame_number, a.name, 0, a.rows*a.columns-1)
    }
}

/// <summary>Jump to a row in the sprite-sheet.</summary>
/// <param name="row_number">The row number in the sprite sheet. (Zero-based)</param>
go_to_row :: proc(a: ^Animator, row_number: uint) {
	if row_number >= a.rows
	{
		a.frame_rec.y = (f32(a.rows) - 1) * a.frame_height
		a.current_row = a.rows - 1
		a.time_remaining_frames_counter = f32(get_total_time_in_frames(a))
	}
	else if a.rows >= 1
	{
		a.frame_rec.y = f32(row_number) == 0 ? 0 : f32(row_number) * a.frame_height
		a.current_row = row_number
		a.time_remaining_frames_counter = f32((get_total_time_in_frames(a)) - (row_number*a.columns + a.columns))
	}
}

/// <summary>Jump to a column in the current row.</summary>
/// <param name="column_number">The column number in the sprite sheet. (Zero-based)</param>
go_to_column :: proc(a: ^Animator, column_number: uint) {
	if column_number >= a.columns
	{
		a.frame_rec.x = f32(a.columns - 1) * a.frame_width
		a.current_column = a.columns - 1
		a.current_frame = a.columns - 1
		a.time_remaining_frames_counter = f32(get_total_time_in_frames(a) - a.current_row*a.columns)
	}
	else if a.columns >= 1
	{
		a.frame_rec.x = f32(column_number) == 0 ? 0 : f32(column_number) * a.frame_width
		a.current_column = column_number
		a.current_frame = column_number
		a.time_remaining_frames_counter = f32(get_total_time_in_frames(a) - a.current_row*a.columns - column_number)
	}
}

/// Jump to the first row.
go_to_first_row :: proc(using a: ^Animator) {
	go_to_row(a, 0)

	// Update time remaining
	time_remaining_frames_counter = f32(get_total_time_in_frames(a) - current_column)
}

/// Jump to the first column.
go_to_first_column :: proc(using a: ^Animator) {
	if (!is_animation_finished)
	{
		go_to_column(a, 0)

		// Update time remaining
		time_remaining_frames_counter := f32(get_total_time_in_frames(a) - (columns * current_row)) if continuous else f32(columns)
	}
	else
	{
		go_to_column(a, 0)
		time_remaining_frames_counter = continuous ? f32(get_total_time_in_frames(a) - get_total_time_in_frames(a) / rows * current_row) : 0
	}
}

/// Jump to the last row.
go_to_last_row :: proc(using a: ^Animator) {
	go_to_row(a, rows - 1)

	// Update time remaining
    time_remaining_frames_counter = f32(get_total_time_in_frames(a) - current_column - columns*(rows-1)) if continuous else f32(columns - current_column)
}

/// Jump to the last column.
go_to_last_column :: proc(using a: ^Animator) {
	if !is_animation_finished
	{
		go_to_column(a, columns - 1)

		// Update time remaining
		if continuous
		{
			if !reverse
			{
				if columns*current_row != 0 {
					time_remaining_frames_counter = f32(get_total_time_in_frames(a) - columns*current_row + columns)
                }
				else {
					time_remaining_frames_counter = f32(get_total_time_in_frames(a) - columns)
                }
			}
			else
			{
				time_remaining_frames_counter = f32(columns*current_row + columns)
			}

		}
		else {
			time_remaining_frames_counter = is_animation_finished ? 0.0 : f32(columns)
        }
	}
	else
	{
		go_to_column(a,columns - 1)
		time_remaining_frames_counter = f32(get_total_time_in_frames(a) - current_row * columns - columns)
	}

}

/// Jump to the first frame in the current row.
go_to_first_frame :: proc(using a: ^Animator) {
	go_to_column(a, 0)

}

/// Jump to the last frame in the current row.
go_to_last_frame :: proc(using a: ^Animator) {
	go_to_column(a, columns - 1)

}

/// Jump to the first frame in the sprite sheet.
go_to_first_frame_of_sprite_sheet :: proc(using a: ^Animator) {
	go_to_row(a, 0)
	go_to_column(a, 0)

}

/// Jump to the last frame in the sprite sheet.
go_to_last_frame_of_sprite_sheet :: proc(using a: ^Animator) {
	go_to_row(a, rows - 1)
	go_to_column(a, columns - 1)
}

/// Jump to the next row index.
next_row :: proc(using a: ^Animator) {
	frame_rec.y += frame_height

	if frame_rec.y >= f32(sprite.height)
	{
		// Go to start
		if can_loop
		{
			frame_rec.y = 0
			current_row = 0
		}
		else // Stay at end
		{
			frame_rec.y = f32(sprite.height)
			current_row = rows - 1
		}

		reset_timer(a)
	}
	else {
		current_row += 1
    }

	// Update the time remaining
	time_remaining_frames_counter = f32(get_total_time_in_frames(a) - (get_total_time_in_frames(a) / rows) * current_row)
}

/// Jump to the previous row index.
previous_row :: proc(using a: ^Animator) {
	frame_rec.y -= frame_height

	if frame_rec.y < 0
	{
		frame_rec.y = f32(sprite.height) - frame_height
		current_row = rows - 1
		reset_timer(a)
	}
	else {
		current_row -= 1
    }

	// Update the time remaining
	if !reverse {
		time_remaining_frames_counter = f32(get_total_time_in_frames(a) - (get_total_time_in_frames(a) / rows) * current_row)
    }
}

/// Jump to the next column index.
next_column :: proc(using a: ^Animator) {
	frame_rec.x += frame_width

	if frame_rec.x > f32(sprite.width)
	{
		frame_rec.x = 0
		current_column = 0
	}
	else {
		current_column += 1
    }

	// Update the time remaining
	time_remaining_frames_counter -= 1
}

/// Jump to the previous column index.
previous_column :: proc(using a: ^Animator) {
	frame_rec.x -= frame_width

	if frame_rec.x < 0
	{
		frame_rec.x = f32(sprite.width) - frame_width
		current_column = columns - 1
	}
	else {
		current_column -= 1
    }

	// Update the time remaining
	time_remaining_frames_counter += 1
}

/// Play animation from the current frame.
play :: proc(using a: ^Animator) {
	if !paused
	{
		playback_position += 1

		// Update the time remaining
		if !is_animation_finished {
			countdown_in_frames(a)
        }

		// Has 'X' amount of frames passed?
		if playback_position > uint(rl.GetFPS()) / framerate
		{
			// Reset playback position
			playback_position = 0

			// Go to previous frame when reversing
			if reverse {
				previous_frame(a)
            }
			else { // Go to next frame if not reversing
				next_frame(a)
            }
		}

		// Only go to next frame if animation has not finished playing
		if !is_animation_finished {
			frame_rec.x = f32(current_frame)*frame_width
        }

		//fmt.printf("Row: %v, Column: %v\n", current_row, current_column)
		has_started_playing = false
	}
}

lerp_anim :: proc(a: ^Animator, speed: f32, constant: bool) {
	a.playback_position += 1
	if a.playback_position > uint(rl.GetFPS()) / a.framerate
	{
		a.playback_position = 0

		if constant {
			a.frame_rec.x += speed * rl.GetFrameTime() 
        }
		else {
			a.frame_rec.x = lerp(a.frame_rec.x, f32(a.sprite.width), speed * rl.GetFrameTime())
        }
	}
}

/// start the animation when it has been paused or has been stopped.
start :: proc(using a: ^Animator) {
	unpause(a)

	if !has_started_playing do has_started_playing = true
}

/// Stop the animation from playing.
stop :: proc(using a: ^Animator) {
	playback_position = 0
	current_column = 0
	current_frame = 0
	current_row = 0
	has_started_playing = true
	is_animation_finished = true

	reset_frame_rec(a)
	reset_timer(a)
	pause(a)
}

/// <summary>pause the animation.</summary>
/// <param name="toggle">If true, flip-flop between pausing and un-pausing the animation every time when called. If false, pause the animation. You need to call unpause to start the animation again.</param>
pause :: proc(a: ^Animator, toggle: bool = false) {
	if toggle
	{
		a.paused = !a.paused
		a.has_started_playing = !a.paused
	}
	else
	{
		a.paused = true
		a.has_started_playing = false
	}
}

/// unpause the animation. (start playing)
unpause :: proc(using a: ^Animator) {
	paused = false
	has_started_playing = true
}

/// Set the play mode to forward.
forward :: proc(using a: ^Animator) {
	if reverse {
		reverse = false
    }
}

/// <summary>Set the play mode to reverse.</summary>
/// <param name="toggle">If true, flip-flop between reversing and un-reversing the play mode every time when called. If false, reverse the play mode. You need to call Forward to un-reverse.</param>
reverse :: proc(a: ^Animator, toggle: bool = false) {
	if toggle
	{
		a.reverse = !a.reverse
		a.time_remaining_frames_counter += f32(get_total_time_in_frames(a)) - a.time_remaining_frames_counter*2
		a.is_animation_finished = false
	}
	else
	{
		a.reverse = true
		a.time_remaining_frames_counter += f32(get_total_time_in_frames(a)) - a.time_remaining_frames_counter*2
		a.is_animation_finished = false
	}
}

/// Restart the animation from the beginning.
restart :: proc(using a: ^Animator) {
	reset_frame_rec(a)
	reset_timer(a)
	has_started_playing = true
}

/// <returns>The total amount of frames in the sprite-sheet.</returns>
get_total_frames :: proc(using a: ^Animator) -> uint {
	return rows * columns
}

/// <returns>The total rows in the sprite-sheet.</returns>
get_total_rows :: proc(using a: ^Animator) -> uint {
	return rows
}

/// <returns>The total columns per row.</returns>
get_total_columns :: proc(using a: ^Animator) -> uint {
	return columns
}

/// <returns>The current frame the animator is on. (Zero based)</returns>
get_current_frame :: proc(using a: ^Animator) -> uint {
	return current_row*columns + current_column
}

/// <returns>The current row the animator is on. (Zero based)</returns>
get_current_row :: proc(using a: ^Animator) -> uint {
	return current_row
}

/// <returns>The current column the animator is on. (Zero based)</returns>
get_current_column :: proc(using a: ^Animator) -> uint {
	return current_column
}

/// <returns>The total time animation will take to finish in frames.</returns>
get_total_time_in_frames :: proc(using a: ^Animator) -> uint {
	return continuous ? columns * rows : columns
}

/// <returns>The time remaining in frames.</returns>
get_time_remaining_in_frames :: proc(using a: ^Animator) -> uint {
	return uint(time_remaining_frames_counter)
}

/// <returns>The total time animation will take to finish in seconds.</returns>
get_total_time_in_seconds :: proc(using a: ^Animator) -> f32 {
	return continuous ? f32(columns * rows / framerate) : f32(columns / framerate)
}

/// <returns>The time remaining in seconds.</returns>
get_time_remaining_in_seconds :: proc(using a: ^Animator) -> f32 {
	return f32(time_remaining_frames_counter) / f32(framerate)
}

/// <returns>The name of the animator.</returns>
get_name :: proc(using a: ^Animator) -> string {
	return name
}

/// <summary>Is the animator currently on the frame number specified?</summary>
/// <param name="frame_number">The frame number to query. (Zero based)</param>
/// <returns>If the animator is on the frame number specified, true. Otherwise, false.</returns>
is_at_frame :: proc(a: ^Animator, frame_number: uint) -> bool {
	// Does frame exist in sprite-sheet
	if (frame_number < a.columns * a.rows)
	{
		row_frame_number_is_on := frame_number / a.columns
		column_frame_number_is_on := frame_number % a.columns

		return is_at_row(a, row_frame_number_is_on) && is_at_column(a, column_frame_number_is_on)
	}

	fmt.printf("ERROR from IsAtFrame(): Frame %v does not exist! %v sprite has frames from %v to %v.\n", frame_number, a.name, 0, a.rows*a.columns-1)
	return false
}

/// <summary>Is the animator currently on the row number specified?</summary>
/// <param name="row_number">The row number to query. (Zero based)</param>
/// <returns>If the animator is on the row number specified, true. Otherwise, false.</returns>
is_at_row :: proc(a: ^Animator, row_number: uint) -> bool {
	if row_number < a.rows {
		return row_number == a.current_row
    }

	fmt.print("ERROR from is_at_row(): Row does not exist!\n")
	return false
}

/// <summary>Is the animator currently on the column number specified?</summary>
/// <param name="column_number">The column number to query. (Zero based)</param>
/// <returns>If the animator is on the column number specified, true. Otherwise, false.</returns>
is_at_column :: proc(a: ^Animator, column_number: uint) -> bool {
	if column_number < a.columns {
		return column_number == a.current_column
    }

	fmt.print("ERROR from is_at_column(): Column does not exist!\n")
	return false
}

/// <summary>Is the animator currently on the first frame of the sprite-sheet?</summary>
/// <returns>If the animator is on the first frame of the sprite-sheet, true. Otherwise, false.</returns>
is_at_first_frame_of_sprite_sheet :: proc(using a: ^Animator) -> bool {
	return is_at_first_row(a) && is_at_first_column(a)
}

/// <summary>Is the animator currently on the last frame of the sprite-sheet?</summary>
/// <returns>If the animator is on the last frame of the sprite-sheet, true. Otherwise, false.</returns>
is_at_last_frame_of_sprite_sheet :: proc(using a: ^Animator) -> bool {
	return is_at_last_row(a) && is_at_last_column(a)
}

/// <summary>Is the animator currently on the first frame of a current row?</summary>
/// <returns>If the animator is on the first frame, true. Otherwise, false.</returns>
is_at_first_frame :: proc(using a: ^Animator) -> bool {
	return continuous ? is_at_first_row(a) && is_at_first_column(a) : is_at_first_column(a)
}

/// <summary>Is the animator currently on the last frame of a current row?</summary>
/// <returns>If the animator is on the last frame, true. Otherwise, false.</returns>
is_at_last_frame :: proc(using a: ^Animator) -> bool {
	return continuous ? is_at_last_row(a) && is_at_last_column(a) : is_at_last_column(a)
}

/// <summary>Is the animator currently on the first row of the sprite-sheet?</summary>
/// <returns>If the animator is on the first row, true. Otherwise, false.</returns>
is_at_first_row :: proc(using a: ^Animator) -> bool {
	return current_row == 0
}

/// <summary>Is the animator currently on the first column of a current row?</summary>
/// <returns>If the animator is on the first column, true. Otherwise, false.</returns>
is_at_first_column :: proc(using a: ^Animator) -> bool {
	return current_column == 0
}

/// <summary>Is the animator currently on the last row of the sprite-sheet?</summary>
/// <returns>If the animator is on the last row, true. Otherwise, false.</returns>
is_at_last_row :: proc(using a: ^Animator) -> bool {
	return current_row == rows - 1
}

/// <summary>Is the animator currently on the last column of a current row?</summary>
/// <returns>If the animator is on the last column, true. Otherwise, false.</returns>
is_at_last_column :: proc(using a: ^Animator) -> bool {
	return current_column == columns - 1
}

/// <summary>Is the animator currently playing?</summary>
/// <returns>If the animator is currently playing, true. Otherwise, false.</returns>
is_playing :: proc(using a: ^Animator) -> bool {
	if can_loop {
		return !paused
    }
	
	if !can_loop && continuous {
		return !is_animation_finished
    }

	return !is_animation_finished
}

/// <summary>Has the animator started playing?</summary>
/// <returns>If the animator started playing, true. Otherwise, false.</returns>
is_started_playing :: proc(using a: ^Animator) -> bool {
	if is_at_first_frame(a)
	{
		reset_timer(a)
		return true
	}

	return has_started_playing
}

/// <summary>Has the animator finished playing?</summary>
/// <returns>If the animator has animator finished playing, true. Otherwise, false.</returns>
is_finished_playing :: proc(using a: ^Animator) -> bool {
	if is_at_last_frame(a)
	{
		reset_timer(a)
		return true
	}

	if !can_loop {
		return is_animation_finished
    }

	return is_animation_finished
}

/// <returns>The Frame rectangle. (Used for drawing the sprite)</returns>
get_frame_rec :: proc(using a: ^Animator) -> rl.Rectangle {
	return frame_rec
}

/// <returns>The sprite texture.</returns>
get_sprite :: proc(using a: ^Animator) -> rl.Texture2D {
	return sprite
}

/// Counts down in frames. Used for timing functionality.
@(private)
countdown_in_frames :: proc(using a: ^Animator) {
	if time_remaining_frames_counter != 0.0 {
		time_remaining_frames_counter -= f32(rl.GetFrameTime() < 0.01 ? f32(framerate) * rl.GetFrameTime() : 0.0)
    }

	if time_remaining_frames_counter <= 0.0 {
		time_remaining_frames_counter = 0.0
    }
}

/// Resets the timer to beginning.
@(private)
reset_timer :: proc(using a: ^Animator) {
	time_remaining_frames_counter = f32(get_total_time_in_frames(a))
}

/// Resets the frame rectangle properties.
@(private)
reset_frame_rec :: proc(using a: ^Animator) {
	frame_rec.width = f32(flip_h ? -uint(sprite.width) / columns : uint(sprite.width) / columns)
	frame_rec.height = f32(flip_v ? -uint(sprite.height) / rows : uint(sprite.height) / rows)
	frame_width =  frame_rec.width
	frame_height = frame_rec.height
	frame_rec.x = reverse && continuous ? f32(sprite.width) - frame_width : 0
	frame_rec.y = reverse && continuous ? f32(sprite.height) - frame_height : 0

	current_frame = reverse ? columns - 1 : 0
	current_row = reverse ? rows - 1 : 0
	current_column = reverse ? columns - 1 : 0
}

/// Jumps to the next frame in the sprite-sheet.
@(private)
next_frame :: proc(using a: ^Animator) {
	// Only increment when animation is playing
	if !is_animation_finished
	{
		current_frame += 1
		current_column += 1
	}

	if can_loop
	{
		// Are we over the max columns
		if current_frame > columns - 1
		{
			// If we are continuous, Go to the next row in the sprite-sheet
			if (continuous)
			{
				next_row(a)
				go_to_first_column(a)
			}
			else // Otherwise, Go back to the start
			{
				go_to_first_column(a)
			}
		}
	}
	else
	{
		// Are we over the max columns
		if current_frame > columns - 1
		{
			// If we are continuous, Go to the next row in the sprite-sheet
			if continuous
			{
				// Clamp values back down
				current_frame = columns - 1
				current_column = columns - 1

				// Go to next row if we are not at the last frame
				if !is_at_last_frame(a)
				{
					next_row(a)
					go_to_first_column(a)
				}
				else {
 					is_animation_finished = true
                }
				
			}
			else // Otherwise, Stay at the end
			{
				is_animation_finished = true
				go_to_last_column(a)
			}
		}
	}
}

/// Jumps to the previous frame in the sprite-sheet.
@(private)
previous_frame :: proc(using a: ^Animator) {
	// Only decrement when animation is playing
	if !is_animation_finished
	{
		current_frame -= 1
		current_column -= 1
	}

	if can_loop
	{
		// Are we over the max columns OR equal to zero
		if current_frame == 0 || current_frame > columns
		{
			// If we are continuous, Go to the previous row in the sprite-sheet
			if continuous
			{
				previous_row(a)
				go_to_last_column(a)
			}
			else // Otherwise, Go back to the last column
			{
				go_to_last_column(a)
			}
		}
	}
	else
	{
		// Are we over the max columns OR equal to zero
		if current_frame == 0 || current_frame > columns
		{
			// If we are continuous, Go to the previous row in the sprite-sheet
			if continuous
			{
				// Clamp values back down
				current_frame = 0
				current_column = 0

				// Go to previous row if we are not at the first frame
				if (!is_at_first_frame(a))
				{
					previous_row(a)
					go_to_last_column(a)
				}
				else {
					is_animation_finished = true
                }
			}
			else // Otherwise, Stay at the start
			{
				is_animation_finished = true
				go_to_first_column(a)
			}
		}
	}
}

@(private)
lerp :: proc(start, end, alpha: f32) -> f32
{
	return (1.0 - alpha) * start + alpha * end
}
