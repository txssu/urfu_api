Mimic.copy(UrFUAPI.UBU.Client)
Mimic.copy(UrFUAPI.IStudent.Client)

ExUnit.start(exclude: :integration, capture_log: true)
