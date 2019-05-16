pragma solidity >=0.4.21 <0.6.0;

contract MyContract {
    struct Student {
        string studentName;
        string gender;
        uint age;
    }
   
    mapping(uint256 => Student) studentInfo;
   
    function setStudentInfo(uint _studentId, string memory _name, string memory _gender, uint _age) public {
        Student storage student = studentInfo[_studentId];
       
        student.studentName = _name;
        student.gender = _gender;
        student.age = _age;
    }
   
    function getStudentInfo(uint256 _studentId) public view returns (string memory, string memory, uint) {
        return (studentInfo[_studentId].studentName, studentInfo[_studentId].gender, studentInfo[_studentId].age);
    }
}