function walltime()
    use numz
    real(b8) walltime
    integer count,count_rate,count_max
    call system_clock(count,count_rate,count_max)
    walltime=real(count,b8)/real(count_rate,b8)
end function walltime
